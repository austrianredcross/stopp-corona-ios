//
// DebugViewModel.swift
// CoronaContact
//

import UIKit
import Resolver

// swiftlint:disable:line_length
let simulatedKey = "MIGJAoGBAMvH7iUvrAODD2NwS7ZRRFrr31sJdJHpvhFaR4EZt6lIZvXFzWnqdvRCg3VmpdsJtqzsZEzsFhINXSfNpXAFj2Sb67Yrs4kWhVtEXq" +
        "I0wuYVH0qsCvfnqGTqYiyp+LzD66FkmCnVvnFxoTaQOB3K0B3DPEkgAlmLQdSgYWfIj1Z3AgMBAAE="

// swiftlint:enable:line_length

class DebugViewModel: ViewModel {
    weak var viewController: DebugViewController?
    weak var coordinator: DebugCoordinator?

    @Injected var dba: DatabaseService
    @Injected var crypto: CryptoService
    @Injected var network: NetworkService
    @Injected var p2pKitService: P2PKitService
    @Injected var notificationService: NotificationService
    var timer: Timer?
    var numberOfContacts = 0

    init(coordintator: DebugCoordinator) {
        self.coordinator = coordintator

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateView),
                                               name: .P2PPeersChanged,
                                               object: nil)
    }

    @objc func viewWillAppear() {
        updateView()
    }

    @objc func updateView() {
        if let timer = timer { timer.invalidate(); }
        timer = Timer(fireAt: Date().addingTimeInterval(2),
                      interval: 0,
                      target: self,
                      selector: #selector(updateView), userInfo: nil, repeats: false)

        viewController?.p2pID.text = "MyID: \(crypto.getMyPublicKeyPrefix() ?? "")"

        let events = dba.getP2PKitEvents()
        viewController?.updateP2PStack(events: events)

        if let timer = timer { RunLoop.main.add(timer, forMode: .common) }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func close() {
        coordinator?.finish(animated: true)
    }

    func shareLog() {
        coordinator?.shareLog()
    }

    func resetLog() {
        LoggingService.deleteLogFile()
    }

    func addHandShakes() {
        var date = Date()
        let calendar = Calendar.current

        for _ in 1...3 {
            let rco = RemoteContact(name: "1234", key: Data(base64Encoded: simulatedKey)!, timestamp: date)
            _ = dba.saveContact(rco)
            date = calendar.date(byAdding: .hour, value: -2, to: date)!
        }
    }

    func addRedInfectionMessage() {
        let date = Calendar.current.date(byAdding: .hour, value: -2, to: Date())!
        dba.saveIncomingInfectionWarning(uuid: UUID().uuidString, warningType: .red, contactTimeStamp: date)
    }

    func addYellowInfectionMessage() {
        let date = Calendar.current.date(byAdding: .hour, value: -2, to: Date())!
        dba.saveIncomingInfectionWarning(uuid: UUID().uuidString, warningType: .yellow, contactTimeStamp: date)
    }

    func scheduleTestNotifications() {
        notificationService.showTestNotifications()
    }

    func attestSickness() {
        dba.saveSicknessState(true)
    }
}
