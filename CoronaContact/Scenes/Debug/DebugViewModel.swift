//
// DebugViewModel.swift
// CoronaContact
//

import Resolver
import UIKit

// swiftlint:disable:line_length
let simulatedKey = "MIGJAoGBAMvH7iUvrAODD2NwS7ZRRFrr31sJdJHpvhFaR4EZt6lIZvXFzWnqdvRCg3VmpdsJtqzsZEzsFhINXSfNpXAFj2Sb67Yrs4kWhVtEXq" +
        "I0wuYVH0qsCvfnqGTqYiyp+LzD66FkmCnVvnFxoTaQOB3K0B3DPEkgAlmLQdSgYWfIj1Z3AgMBAAE="

// swiftlint:enable:line_length

class DebugViewModel: ViewModel {
    weak var viewController: DebugViewController?
    weak var coordinator: DebugCoordinator?

    @Injected private var dba: DatabaseService
    @Injected private var localStorage: LocalStorage
    @Injected private var network: NetworkService
    @Injected private var notificationService: NotificationService
    @Injected private var exposureManager: ExposureManager

    var timer: Timer?
    var numberOfContacts = 0

    init(coordinator: DebugCoordinator) {
        self.coordinator = coordinator
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

    func scheduleTestNotifications() {
        notificationService.showTestNotifications()
    }

    func attestSickness() {
        localStorage.attestedSicknessAt = Date()
    }

    func exposeDiagnosesKeys(test: Bool = false) {
        if test {
            exposureManager.getTestDiagnosisKeys { error in
            }
        } else {
            exposureManager.getDiagnosisKeys { error in
            }
        }
    }

}
