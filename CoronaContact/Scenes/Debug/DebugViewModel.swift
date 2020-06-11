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
        viewController?.moveSickReportButton.isHidden = true
        switch healthRepository.userHealthStatus {
        case .isHealthy:
            break
        case .isUnderSelfMonitoring:
            text = "User is self monitoring"
        case .isProbablySick:
            text = "User is probably sick"
            viewController?.revokeProbablySickButton.isHidden = false
            viewController?.probablySickButton.isHidden = true
            viewController?.moveSickReportButton.isHidden = false
        case .hasAttestedSickness:
            text = "User is attested sick"
            viewController?.revokeAttestedSickButton.isHidden = false
            viewController?.probablySickButton.isHidden = true
            viewController?.attestedSickButton.isHidden = true
            viewController?.moveSickReportButton.isHidden = false
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

    func moveSickReportBackADay() {
        localStorage.isProbablySickAt = localStorage.isProbablySickAt?.addDays(-1)
        localStorage.attestedSicknessAt = localStorage.attestedSicknessAt?.addDays(-1)
        localStorage.missingUploadedKeysAt = localStorage.missingUploadedKeysAt?.addDays(-1)
    }

    func revokeProbablySick() {
        healthRepository.revokeProbablySick()
    }

    func revokeAttestedSick() {
        healthRepository.revokeProvenSickness()
    }

    func exposeDiagnosesKeys() {
        let debugFun: (Result<[ENTemporaryExposureKey], Error>) -> Void = { keyResult in
            if case let .success(keys) = keyResult {
                /*                let ukeys = self.exposureKeyManager.getKeysForUpload(from: Date().addDays(-14)!, untilIncluding: Date())
                                ukeys?.forEach { key in
                                    LoggingService.debug("ExposureKey: \(key.intervalNumber) \(key.intervalNumberDate) \(key.password.prefix(10))")
                                }
                 */
            }
        }
        exposureManager.getDiagnosisKeys(completion: debugFun)
    }

    deinit {
        for observer in observers {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
