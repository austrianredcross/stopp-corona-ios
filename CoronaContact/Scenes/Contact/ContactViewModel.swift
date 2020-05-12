//
//  MainViewModel.swift
//  CoronaContact
//

import Foundation
import Resolver

class ContactViewModel: ViewModel {
    weak var coordinator: ContactCoordinator?
    weak var viewController: ContactViewController?
    @Injected private var nearbyService: NearbyService
    @Injected private var crypto: CryptoService
    @Injected private var p2pkit: P2PKitService
    var isActive: Bool { nearbyService.isSharing }
    var errors: PermissionErrors = PermissionErrors(microphone: false, bluetooth: false, nearby: false)
    var sharingEnabled = true
    var ownRemoteId: String { crypto.generatedName }

    init(with coordinator: ContactCoordinator) {
        self.coordinator = coordinator
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateView),
                                               name: .NearbyServiceContactsChanged,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(checkPermissions),
                                               name: .NearbyServicePermissionChange,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(checkPermissions),
                                               name: .NearbyServiceActiveChange,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appWillEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didEnterBackground),
                                               name: UIApplication.didEnterBackgroundNotification,
                                               object: nil)

    }

    func formatContactName(_ name: String) -> String {
        String(format: "handshake_code_%@", String(name.prefix(2))).localized + name.suffix(2)
    }

    @objc func updateView() {
        viewController?.updateView()
        viewController?.updateContactList(nearbyService.contacts)
    }

    @objc func checkPermissions() {
        errors = nearbyService.getPermissionErrors()
        if errors.nearby {
            DispatchQueue.main.async {
                self.nearbyService.grantPermission() // approved by Sven / Sebastian in teams call 26.03. 19:25
            }
            return
        }
        updateView()
        if !errors.any {
            startSharing()
        }
    }

    @objc func appWillEnterForeground() {
        sharingEnabled = true
        viewController?.updateContactList(nearbyService.contacts)
        nearbyService.resetPermissionErrors()
        checkPermissions()
    }

    @objc func didEnterBackground() {
        sharingEnabled = false
        nearbyService.stopSharing()
    }

    func startSharing() {
        if isActive || !sharingEnabled { return }
        guard var data = ownRemoteId.data(using: .utf8) else { return }
        let pubKey = self.crypto.getPublicKey()
        guard let pubkey = pubKey else { return }
        data.append(pubkey)
        self.nearbyService.startSharing(data)
    }

    func viewOpening() {
        showMicrophoneInfo()
        checkPermissions()
    }

    func viewClosed() {
        coordinator?.finish()
    }

    func viewClosing() {
        nearbyService.stopSharing()
    }

    func toggleContactAtIndex(_ index: Int) {
        if !nearbyService.contacts[index].saved {
            nearbyService.contacts[index].selected.toggle()
            updateView()
        }
    }

    func toggleAllContacts(isSelected: Bool) {
        nearbyService.contacts.indices.forEach { index in
            guard !nearbyService.contacts[index].saved else {
                return
            }

            nearbyService.contacts[index].selected = isSelected
        }

        updateView()
    }

    func numberOfContacts() -> Int {
        nearbyService.contacts.count
    }

    func saveContacts() {
        nearbyService.saveContacts()
    }

    func getContactAtIndex(_ index: Int) -> RemoteContact {
        nearbyService.contacts[index]
    }

    func nearbyPermissionGranted() {
        nearbyService.grantPermission()
    }

    func showHelp() {
        coordinator?.showHelp()
    }

    func shareApp() {
        coordinator?.shareApp()
    }

    func showMicrophoneInfo() {
        if UserDefaults.standard.hideMicrophoneInfoDialog {
            return
        }

        coordinator?.microphoneInfo()
    }

    deinit {
        print("---- DEINIT \(self)")
        NotificationCenter.default.removeObserver(self)
    }

}
