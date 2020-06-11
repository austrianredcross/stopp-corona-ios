//
//  AppUpdateService.swift
//  CoronaContact
//

import Resolver
import UIKit

class AppUpdateService {
    private var window: UIWindow? {
        UIWindow.key
    }

    private var isDisplayingUpdateAlert = false

    @Injected
    private var maintenanceTaskRepository: MaintenanceTaskRepository

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

    func performMaintenanceTasks() {
        let tasks = maintenanceTaskRepository.newMaintenanceTasks
        guard !tasks.isEmpty else {
            return
        }
        for task in tasks {
            task.performMaintenance(completion: { _ in })
        }
        maintenanceTaskRepository.currentMaintenancePerformed()
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
