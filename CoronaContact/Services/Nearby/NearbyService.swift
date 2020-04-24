//
//  NearbyService.swift
//  CoronaContact
//

import Foundation
import Resolver

extension Notification.Name {
    static let NearbyServiceContactsChanged = Notification.Name("nsc_changed")
    static let NearbyServicePermissionChange = Notification.Name("nsc_perm")
    static let NearbyServiceActiveChange = Notification.Name("nsc_active")
}

struct PermissionErrors {
    let microphone: Bool
    let bluetooth: Bool
    let nearby: Bool
    var any: Bool { nearby || bluetooth || microphone }
}

class NearbyService {
    var microphoneError = false
    var bluetoothError = false
    #if targetEnvironment(simulator)
    var simulatedSharing = false
    #endif
    var isSharing: Bool {
        #if targetEnvironment(simulator)
        return simulatedSharing
        #else
        return publication != nil
        #endif
    }

    @Injected private var databaseService: DatabaseService
    private var log = LoggingService.self

    lazy var messageManager: GNSMessageManager? = {
        GNSMessageManager(apiKey: AppConfiguration.googleNearbyApiKey, paramsBlock: { [weak self] (params: GNSMessageManagerParams?) in
            guard let params = params else { return }
            params.microphonePermissionErrorHandler = { (hasError: Bool) in
                self?.microphoneError = true
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .NearbyServicePermissionChange, object: nil)
                }
            }
            params.bluetoothPowerErrorHandler = { (hasError: Bool) in
                self?.bluetoothError = true
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .NearbyServicePermissionChange, object: nil)
                }
            }
            params.bluetoothPermissionErrorHandler = { (hasError: Bool) in
                self?.bluetoothError = true
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .NearbyServicePermissionChange, object: nil)
                }
            }
        })
    }()

    var publication: GNSPublication?
    var subscription: GNSSubscription?
    var nearbyPermission: GNSPermission?
    var newContactNotification: NotificationToken?
    var contacts: [RemoteContact] = []

    let showAlreadySavedDuration: Double = 4500 /// 1 hour 15 minutes

    init() {
        // Enable debug logging to help track down problems.
        // GNSMessageManager.setDebugLoggingEnabled(true)
        nearbyPermission = GNSPermission(changedHandler: { (_: Bool) in
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .NearbyServicePermissionChange, object: nil)
            }
        })
        newContactNotification = NotificationCenter.default.observe(name: .DatabaseServiceNewContact,
                                                                    object: nil,
                                                                    queue: nil) { [weak self] notification in
            if let pubKey = notification.userInfo?["pubKey"] as? Data,
               let autoDiscovered = notification.userInfo?["autoDiscovered"] as? Bool,
               autoDiscovered == true,
               var contact = self?.contacts.first(where: { $0.key == pubKey }),
               contact.automaticDiscovered == false {
                contact.automaticDiscovered = true
                NotificationCenter.default.post(name: .NearbyServiceContactsChanged, object: nil)
            }
        }
    }

    func parseMessage(_ data: Data) -> RemoteContact? {
        if data.count < 144 {
            log.warning("invalid packet size \(data.count)", context: .nearby)
            return nil
        }
        let name = String(data: data.prefix(4), encoding: .utf8)
        let key = data.subdata(in: 4..<144)
        guard name != nil else { return nil }
        return RemoteContact(name: name!, key: key)
    }

    func saveContacts() {
        for index in contacts.indices {
            if contacts[index].selected && !contacts[index].saved {
                databaseService.saveContact(contacts[index])
                contacts[index].selected = false
                contacts[index].saved = true
            }
        }
        NotificationCenter.default.post(name: .NearbyServiceContactsChanged, object: nil)
    }

    func startSharing(_ data: Data) {
        if let messageMgr = self.messageManager {
            contacts = []
            NotificationCenter.default.post(name: .NearbyServiceContactsChanged, object: nil)
            #if !targetEnvironment(simulator)
            let strategy = GNSStrategy { $0?.discoveryMediums = .audio }
            // Publish the name to nearby devices.
            let pubMessage: GNSMessage = GNSMessage(content: data)
            publication = messageMgr.publication(with: pubMessage, paramsBlock: { $0?.strategy = strategy })

            // Subscribe to messages from nearby devices and update the contacts array
            subscription = messageMgr.subscription(messageFoundHandler: { [weak self] (message: GNSMessage?) -> Void in
                guard let message = message else { return }
                guard var contact = self?.parseMessage(message.content) else { return }

                if let rcontact = self?.databaseService.getContactByPublicKey(contact.key),
                    (Date().timeIntervalSince1970 - rcontact.timestamp.timeIntervalSince1970 < self?.showAlreadySavedDuration ?? 0) {
                    contact.saved = true
                }
                self?.log.info("contact found \(contact)", context: .nearby)
                if let index = self?.contacts.firstIndex(where: { $0.key == contact.key }) {
                    self?.contacts[index].removed = false
                    self?.contacts[index].name = contact.name
                } else {
                    self?.contacts.append(contact)
                }
                NotificationCenter.default.post(name: .NearbyServiceContactsChanged, object: nil)
            }, messageLostHandler: { [weak self] (message: GNSMessage?) -> Void in
                guard let message = message else { return }
                guard let contact = self?.parseMessage(message.content) else { return }
                var updated = false
                if let index = self?.contacts.firstIndex(where: { $0.key == contact.key && $0.name == contact.name }) {
                    self?.log.info("contact lost \(self?.contacts[index])", context: .nearby)
                    self?.contacts[index].removed = true
                    updated = true
                }
                if updated { NotificationCenter.default.post(name: .NearbyServiceContactsChanged, object: nil) }
            }, paramsBlock: { $0?.strategy = strategy })
            #else
            simulatedSharing = true
            let simulatedKey = Data(base64Encoded: "MIGJAoGBAMvH7iUvrAODD2NwS7ZRRFrr31sJdJHpvhFaR4EZt6lIZvXFzWnqdvRCg3VmpdsJtqzsZEzsFhINXS" +
                    "fNpXAFj2Sb67Yrs4kWhVtEXqI0wuYVH0qsCvfnqGTqYiyp+LzD66FkmCnVvnFxoTaQOB3K0B3DPEkgAlmLQdSgYWfIj1Z3AgMBAAE=")!
            var contact = RemoteContact(name: "1234", key: simulatedKey)
            if let rcontact = self.databaseService.getContactByPublicKey(contact.key),
                (Date().timeIntervalSince1970 - rcontact.timestamp.timeIntervalSince1970 < showAlreadySavedDuration) {
                contact.saved = true
            }
            contacts.append(contact)
            NotificationCenter.default.post(name: .NearbyServiceContactsChanged, object: nil)
            #endif
        }
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .NearbyServiceActiveChange, object: nil)
        }
    }

    func stopSharing() {
        publication = nil
        subscription = nil
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .NearbyServiceActiveChange, object: nil)
            NotificationCenter.default.post(name: .NearbyServiceContactsChanged, object: nil)
        }
    }

    func grantPermission() {
        GNSPermission.setGranted(true)
    }

    func checkPermissions() -> Bool {
        GNSPermission.isGranted()
    }

    func resetPermissionErrors() {
        microphoneError = false
        bluetoothError = false
    }

    func getPermissionErrors() -> PermissionErrors {
        PermissionErrors(microphone: microphoneError, bluetooth: bluetoothError, nearby: !GNSPermission.isGranted())
    }

    deinit {
        nearbyPermission = nil
    }
}
