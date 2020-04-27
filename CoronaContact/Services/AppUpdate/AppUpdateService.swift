//
//  AppUpdateService.swift
//  CoronaContact
//

import UIKit

class AppUpdateService {

    private var window: UIWindow? {
        UIApplication.shared.keyWindow
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

    private func openAppStore() {
        guard let appStoreAppId = UIApplication.appStoreAppId else {
            print("App Store App Id is not present")
            return
        }

        guard let url = URL(string: "itms-apps://itunes.apple.com/app/\(appStoreAppId)"),
            UIApplication.shared.canOpenURL(url) else {
                print("Can't Open App Store on the simulator")
                return
        }

        UIApplication.shared.open(url, options: [:])
    }
}
