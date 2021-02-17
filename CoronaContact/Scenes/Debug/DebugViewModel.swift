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
        observers.append(localStorage.$lastYellowContact.addObserver(using: updateView))
        observers.append(localStorage.$lastRedContact.addObserver(using: updateView))
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
        if localStorage.lastYellowContact != nil {
            viewController?.yellowButton.transKeyNormal = "- Yellow"
        } else {
            viewController?.yellowButton.transKeyNormal = "+ Yellow"
        }
        viewController?.yellowButton.updateTranslation()
        if localStorage.lastRedContact != nil {
            viewController?.redButton.transKeyNormal = "- Red"
        } else {
            viewController?.redButton.transKeyNormal = "+ Red"
        }
        viewController?.redButton.updateTranslation()
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
        healthRepository.setProbablySick(from: Date())
    }

    func attestSickness() {
        healthRepository.setProvenSick(from: Date())
    }

    func moveSickReportBackADay() {
        localStorage.isProbablySickAt = localStorage.isProbablySickAt?.addDays(-1)
        localStorage.attestedSicknessAt = localStorage.attestedSicknessAt?.addDays(-1)
        localStorage.missingUploadedKeysAt = localStorage.missingUploadedKeysAt?.addDays(-1)
    }

    func yellowExposureButtonToggle() {
        if localStorage.lastYellowContact == nil {
            localStorage.lastYellowContact = Date().addDays(-1)
        } else {
            localStorage.lastYellowContact = nil
        }
    }

    func redExposureButtonToggle() {
        if localStorage.lastRedContact == nil {
            localStorage.lastRedContact = Date().addDays(-1)
        } else {
            localStorage.lastRedContact = nil
        }
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
        if case let .success(riskResult) = result {
            localStorage.performedBatchProcessingAt = Date()
            localStorage.performedBatchProcessingDates.managingBatchProcessingDates(insert: Date())
            QuarantineTimeController.quarantineTimeCalculation(riskResult: riskResult)
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
