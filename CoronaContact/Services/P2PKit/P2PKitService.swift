//
//  p2pkitService.swift
//  CoronaContact
//

import UIKit
import Resolver

extension Notification.Name {
    static let P2PPeersChanged = Notification.Name("p2p_changed")
    static let P2PDiscoveryChanged = Notification.Name("p2p_active")
}

#if DEBUG
let stateRestoration = false
#else
let stateRestoration = true
#endif

class P2PKitService: NSObject {
    @Injected private var crypto: CryptoService
    @Injected private var database: DatabaseService
    var myPeerID: String { PPKController.myPeerID() }
    private var log = LoggingService.self
    private var sickObserver: NotificationToken?
    private var backgroundObserver: NotificationToken?
    private var foregroundObserver: NotificationToken?
    private var isEnabled = false
    private var timer: Timer?
    var isActive = false
    var updateIsRunning = false
    var unauthorized = false // since the app is killed when authorizations changes we only set this to true
    var state: PPKDiscoveryState? {
        didSet {
            if oldValue != state { NotificationCenter.default.post(name: .P2PDiscoveryChanged, object: self) }
        }
    }

    let weights: [Double] = [0, 0, 0, 1, 2, 15]
    /// 1 minute
    let detectionInterval: TimeInterval = 60.0 * 60.0
    let intensiveContactScore = 30.0

    override init() {
        super.init()
        sickObserver = NotificationCenter.default.observe(name: .DatabaseSicknessUpdated,
                                                          object: nil,
                                                          queue: .main) { [weak self] _ in
            if UserDefaults.standard.hasAttestedSickness {
                if let self = self, self.isActive { self.stop() }
            }
        }
        backgroundObserver = NotificationCenter.default.observe(name: UIApplication.didEnterBackgroundNotification,
                                                                object: nil,
                                                                queue: .main) { [weak self] _ in
            self?.database.saveP2PKitEventForAllPubkeys(strength: 0)
            self?.log.warning("saved 'lost' events for all peers. going into background", context: .p2pkit)
        }
        database.deleteP2PKitEvents()
    }

    func enable() {
        PPKController.enable(withConfiguration: AppConfiguration.p2pKitApiKey, observer: self)
        removeOldP2PKitEvents()
        log.debug("enabled", context: .p2pkit)
    }

    private func removeOldP2PKitEvents() {
        let now = Date()
        let intervalStart = now.addingTimeInterval(-detectionInterval)
        database.deleteP2PKitEventsBefore(endtime: intervalStart)
    }

    private func runTimer(timer: Timer) { checkScores() }

    func calculateScoreFor(_ event: P2PKitEvent, _ intervalStart: Date, _ now: Date) -> Double {
        let start = event.start < intervalStart ? intervalStart.timeIntervalSince1970 : event.start.timeIntervalSince1970
        let end = (event.end ?? now).timeIntervalSince1970
        return (end - start) / 60 * weights[event.signalStrength]
    }

    func checkScores() {
        assert(Thread.isMainThread)
        if updateIsRunning { return }
        updateIsRunning = true
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            self.log.verbose("running checkScores", context: .p2pkit)
            let now = Date()
            let intervalStart = now.addingTimeInterval(-self.detectionInterval)
            self.database.deleteP2PKitEventsBefore(endtime: intervalStart)

            let eventDict = Dictionary(grouping: self.database.getP2PKitEvents(), by: { $0.pubKey })

            for (currentPubKey, events) in eventDict {
                var currentScore = 0.0

                events.forEach { event in currentScore += self.calculateScoreFor(event, intervalStart, now) }

                let prefix = self.crypto.getPublicKeyPrefix(publicKey: currentPubKey)
                if currentScore > self.intensiveContactScore {
                    self.database.saveContact(RemoteContact(name: "", key: currentPubKey, automaticDiscovered: true))
                    self.log.debug("adding \(prefix) to contacts with \(currentScore) Points", context: .p2pkit)
                } else {
                    self.log.verbose("\(prefix) Current Score: \(currentScore) Points", context: .p2pkit)
                }
            }

            self.updateIsRunning = false
        }
    }

    func start() {
        if isActive || !isEnabled { return }
        if let timer = timer { timer.invalidate() }
        timer = Timer(fire: Date().addingTimeInterval(2), interval: 60, repeats: true, block: runTimer)
        if let timer = timer { RunLoop.main.add(timer, forMode: .common) }

        PPKController.startDiscovery(withDiscoveryInfo: crypto.getPublicKey(), stateRestoration: stateRestoration)
        PPKController.enableProximityRanging()
        log.info("discovery started with id: \(myPeerID)", context: .p2pkit)
        UserDefaults.standard.backgroundHandShakeDisabled = false
        isActive = true
    }

    func stop() {
        if !isActive { return }
        PPKController.stopDiscovery()
        database.saveP2PKitEventForAllPubkeys(strength: 0)
        log.warning("stopped. saved 'lost' events for all peers.", context: .p2pkit)
        timer?.invalidate()
        timer = nil
        UserDefaults.standard.backgroundHandShakeDisabled = true
        isActive = false
        log.info("discovery stopped", context: .p2pkit)
    }

    func getPublicKeyFromDiscoverInfo(_ peer: PPKPeer) -> Data? {
        if let data = peer.discoveryInfo {
            return data.prefix(140)
        }
        return nil
    }
}

// MARK: PPKControllerDelegate

extension P2PKitService: PPKControllerDelegate {
    func ppkControllerInitialized() {
        log.debug("initialized", context: .p2pkit)
        isEnabled = true
        if !UserDefaults.standard.backgroundHandShakeDisabled && UserDefaults.standard.hasSeenOnboarding {
            start()
        }
    }

    func discoveryStateChanged(_ state: PPKDiscoveryState) {
        switch state {
        case .running:
            log.info("PPKDiscoveryState running", context: .p2pkit)
        case .stopped:
            log.info("PPKDiscoveryState stopped", context: .p2pkit)
        case .unsupported:
            log.info("PPKDiscoveryState unsupported", context: .p2pkit)
        case .unauthorized:
            log.info("PPKDiscoveryState unauthorized", context: .p2pkit)
            unauthorized = true
            stop()
        case .suspended:
            log.info("PPKDiscoveryState suspended", context: .p2pkit)
        case .serverConnectionUnavailable:
            log.info("PPKDiscoveryState serverConnectionUnavailable", context: .p2pkit)
        @unknown default:
            log.info("PPKDiscoveryState default", context: .p2pkit)
        }
        if self.state == .running && state != .running {
            log.warning("state changed. saved 'lost' events for all peers.", context: .p2pkit)
            database.saveP2PKitEventForAllPubkeys(strength: 0)
        }
        self.state = state
    }

    func peerDiscovered(_ peer: PPKPeer) {
        if let pubKey = getPublicKeyFromDiscoverInfo(peer), peer.proximityStrength != .unknown {
            database.saveP2PKitEvent(pubKey: pubKey, strength: peer.proximityStrength.rawValue)
            assert(Thread.isMainThread)
            NotificationCenter.default.post(name: .P2PPeersChanged, object: self)
            let prefix = crypto.getPublicKeyPrefix(publicKey: pubKey)
            log.info("new peer discovered id: \(peer.peerID) - \(prefix)", context: .p2pkit)
        } else {
            log.warning("new peer discovered id: \(peer.peerID) NO PUBLIC KEY FOUND!", context: .p2pkit)
        }
    }

    func peerLost(_ peer: PPKPeer) {
        if let pubKey = getPublicKeyFromDiscoverInfo(peer), peer.proximityStrength != .unknown {
            database.saveP2PKitEvent(pubKey: pubKey, strength: 0)
        }
        log.info("lost peer id: \(peer.peerID)", context: .p2pkit)
        DispatchQueue.main.async { NotificationCenter.default.post(name: .P2PPeersChanged, object: self) }
    }

    func proximityStrengthChanged(for peer: PPKPeer) {
        if let pubKey = getPublicKeyFromDiscoverInfo(peer), peer.proximityStrength != .unknown {
            database.saveP2PKitEvent(pubKey: pubKey, strength: peer.proximityStrength.rawValue)
            let prefix = crypto.getPublicKeyPrefix(publicKey: pubKey)
            log.verbose("peer strength changed \(peer.peerID) (\(prefix)): \(peer.proximityStrength.rawValue)",
                        context: .p2pkit)
        } else {
            log.warning("peer strength changed \(peer.peerID): \(peer.proximityStrength.rawValue) WITHOUT PUBKEY",
                        context: .p2pkit)
        }
        DispatchQueue.main.async { NotificationCenter.default.post(name: .P2PPeersChanged, object: self) }
    }

}
