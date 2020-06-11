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
    @Injected private var batchDownloadService: BatchDownloadService
    @Injected private var riskCalculationController: RiskCalculationController

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

    func downloadSevenDaysBatchAndDailyBatches() {
        _ = batchDownloadService.startBatchDownload(.sevenDaysBatchAndDailyBatches, completionHandler: handleBatchDownloadResult)
    }

    func downloadFourteenDaysBatch() {
        _ = batchDownloadService.startBatchDownload(.onlyFourteenDaysBatch, completionHandler: handleBatchDownloadResult)
    }

    func handleBatchDownloadResult(_ result: Result<[UnzippedBatch], BatchDownloadError>) {
        switch result {
        case let .success(batches):
            riskCalculationController.processBatches(batches, completionHandler: handleRiskCalculationResult)
        case let .failure(error):
            print(error)
        }
    }

    func handleRiskCalculationResult(_ result: Result<RiskCalculationResult, RiskCalculationError>) {
        var lastRedContact: Date?
        var lastYellowContact: Date?

        if case let .success(riskResult) = result {
            for (date, riskType) in riskResult {
                if riskType == .yellow, lastYellowContact == nil || lastYellowContact! < date {
                    lastYellowContact = date
                }
                if riskType == .red, lastRedContact == nil || lastRedContact! < date {
                    lastRedContact = date
                }
            }
            localStorage.lastRedContact = lastRedContact
            localStorage.lastYellowContact = lastYellowContact
        }
    }

    func exposeDiagnosesKeys() {
        exposureManager.getKeysForUpload(from: Date().addDays(-15)!, untilIncluding: Date(), diagnosisType: .red) { result in
            LoggingService.debug("keys: \(result)")
        }
    }

    deinit {
        for observer in observers {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
