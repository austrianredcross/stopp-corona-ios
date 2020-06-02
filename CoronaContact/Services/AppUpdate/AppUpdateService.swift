//
//  AppUpdateService.swift
//  CoronaContact
//

import UIKit

class AppUpdateService {
    private var window: UIWindow? {
        UIWindow.key
    }

    private var isDisplayingUpdateAlert = false

    var requiresUpdate = false {
        didSet {
            if requiresUpdate {
                showUpdateAlertIfNecessary()
            }
        }
    }

    func showUpdateAlertIfNecessary() {
        guard !isDisplayingUpdateAlert, requiresUpdate else {
            return
        }

        let updateAction = UIAlertAction(title: "mandatory_update_button".localized, style: .default, handler: { _ in
            self.openAppStore()
            self.isDisplayingUpdateAlert = false
        })
        let alertViewController = UIAlertController(
            title: "mandatory_update_title".localized,
            message: "mandatory_update_message".localized,
            preferredStyle: .alert
        )
        alertViewController.addAction(updateAction)

        guard let topViewController = window?.topMostViewController else {
            return
        }

        let presentAlert = {
            topViewController.present(alertViewController, animated: true)
            self.isDisplayingUpdateAlert = true
        }

        if let presentedViewController = topViewController.presentedViewController {
            presentedViewController.dismiss(animated: true) {
                presentAlert()
            }
        } else {
            presentAlert()
        }
    }

    func cleanupOldData() {
        removeObseleteUserDefaults()
    }

    private func removeObseleteUserDefaults() {
        let obsoleteKeys = [
            "last_downloaded_message",
            "not_fresh_installed",
            "tracking_id",
            "hide_microphone_info_dialog",
            "is_probably_sick",
            "has_attested_sickness",
        ]
        obsoleteKeys.forEach(UserDefaults.standard.removeObject(forKey:))
    }

    private func openAppStore() {
        guard let url = UIApplication.appStoreAppDeepUrl,
            UIApplication.shared.canOpenURL(url) else {
            print("Can't Open App Store on the simulator")
            return
        }

        UIApplication.shared.open(url, options: [:])
    }
}
