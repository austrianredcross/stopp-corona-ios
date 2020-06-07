//
//  DebugViewModel.swift
//  CoronaContact
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
    private var observers = [NSObjectProtocol]()

    @Injected private var dba: DatabaseService
    @Injected private var localStorage: LocalStorage
    @Injected private var network: NetworkService
    @Injected private var notificationService: NotificationService
    @Injected private var exposureManager: ExposureManager

    init(coordinator: DebugCoordinator) {
        self.coordinator = coordinator
        observers.append(localStorage.$isProbablySickAt.addObserver(using: updateView))
        observers.append(localStorage.$attestedSicknessAt.addObserver(using: updateView))
    }

    func updateView() {
        var text = "User is healthy"
        viewController?.revokeAttestedSickButton.isHidden = true
        viewController?.revokeProbablySickButton.isHidden = true
        viewController?.probablySickButton.isHidden = false
        viewController?.attestedSickButton.isHidden = false

        if localStorage.hasAttestedSickness {
            text = "User is attested sick"
            viewController?.revokeAttestedSickButton.isHidden = false
            viewController?.probablySickButton.isHidden = true
            viewController?.attestedSickButton.isHidden = true
        } else if localStorage.isProbablySick {
            text = "User is probably sick"
            viewController?.revokeProbablySickButton.isHidden = false
            viewController?.probablySickButton.isHidden = true
        }
        viewController?.currentStateLabel.text = text
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

    func probablySickness() {
        localStorage.isProbablySickAt = Date()
    }

    func attestSickness() {
        localStorage.attestedSicknessAt = Date()
    }

    func revokeProbablySick() {
        localStorage.isProbablySickAt = nil
    }

    func revokeAttestedSick() {
        localStorage.attestedSicknessAt = nil
    }

    func exposeDiagnosesKeys(test: Bool = false) {
        if test {
            exposureManager.getTestDiagnosisKeys { _ in
            }
        } else {
            exposureManager.getDiagnosisKeys { _ in
            }
        }
    }

    deinit {
        for observer in observers {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
