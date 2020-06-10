//
//  DebugViewModel.swift
//  CoronaContact
//

import ExposureNotification
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
    @Injected private var exposureKeyManager: ExposureKeyManager
    @Injected private var healthRepository: HealthRepository

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
        switch healthRepository.userHealthStatus {
        case .isHealthy: ()
        case .isUnderSelfMonitoring:
            text = "User is self monitoring"
        case .isProbablySick:
            text = "User is probably sick"
            viewController?.revokeProbablySickButton.isHidden = false
            viewController?.probablySickButton.isHidden = true
        case .hasAttestedSickness:
            text = "User is attested sick"
            viewController?.revokeAttestedSickButton.isHidden = false
            viewController?.probablySickButton.isHidden = true
            viewController?.attestedSickButton.isHidden = true
        }
        viewController?.currentStateLabel.text = text
        viewController?.batchDownloadSchedulerResultLabel.text = localStorage.batchDownloadSchedulerResult
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
        healthRepository.setProbablySick()
    }

    func attestSickness() {
        healthRepository.setProvenSick()
    }

    func revokeProbablySick() {
        healthRepository.revokeProbablySick()
    }

    func revokeAttestedSick() {
        healthRepository.revokeProvenSickness()
    }

    func exposeDiagnosesKeys(test: Bool = false) {
        let debugFun: (Result<[ENTemporaryExposureKey], Error>) -> Void = { keyResult in
            if case let .success(keys) = keyResult {
                let ukeys = try? self.exposureKeyManager.getKeysForUpload(keys: keys)
                ukeys?.forEach { key in
                    LoggingService.debug("ExposureKey: \(key.intervalNumber) \(key.intervalNumberDate) \(key.password.prefix(10))")
                }
            }
        }
        if test {
            exposureManager.getTestDiagnosisKeys(completion: debugFun)
        } else {
            exposureManager.getDiagnosisKeys(completion: debugFun)
        }
    }

    deinit {
        for observer in observers {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
