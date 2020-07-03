//
//  AppStartBatchController.swift
//  CoronaContact
//

import Foundation
import Resolver

final class AppStartBatchController {
    @Injected private var exposureManager: ExposureManager
    @Injected private var localStorage: LocalStorage
    @Injected private var healthRepository: HealthRepository
    @Injected private var batchDownloadService: BatchDownloadService
    @Injected private var riskCalculationController: RiskCalculationController

    private let log = ContextLogger(context: .batchDownload)

    func startBatchProcessing() {
        guard exposureManager.authorizationStatus == .authorized else {
            return
        }

        if let lastTime = timeSinceLastBatchProcessing(), lastTime < BatchDownloadConfiguration.taskCooldownTime {
            log.debug("Skipping batch processing on app start, because it already happened \(Int(lastTime / 60)) minutes ago.")
            return
        }

        log.debug("Starting batch processing on app start.")

        let downloadRequirement = determineDownloadRequirement()
        _ = batchDownloadService.startBatchDownload(downloadRequirement) { [weak self] result in
            guard let self = self else {
                return
            }

            switch result {
            case let .success(batches):
                self.riskCalculationController.processBatches(batches, completionHandler: self.handleRiskCalculationResult)
            case let .failure(error):
                self.log.error("Failed to process batches after app start due to an error: \(error).")
            }
        }
    }

    private func timeSinceLastBatchProcessing() -> TimeInterval? {
        guard let performedBatchProcessingAt = localStorage.performedBatchProcessingAt else {
            return nil
        }

        return Date().timeIntervalSince1970 - performedBatchProcessingAt.timeIntervalSince1970
    }

    private func determineDownloadRequirement() -> BatchDownloadService.DownloadRequirement {
        switch healthRepository.userHealthStatus {
        case .isHealthy:
            return .sevenDaysBatchAndDailyBatches
        case .hasAttestedSickness, .isProbablySick, .isUnderSelfMonitoring:
            return .onlyFourteenDaysBatch
        }
    }

    private func handleRiskCalculationResult(_ result: Result<RiskCalculationResult, RiskCalculationError>) {
        if case let .success(riskResult) = result {
            log.debug("Successfully processed batches after app start.")
            log.debug("Passing the risk calculation result to the quarantine time controller.")
            localStorage.performedBatchProcessingAt = Date()
            QuarantineTimeController.quarantineTimeCalculation(riskResult: riskResult)
        }

        batchDownloadService.removeBatches()
    }
}
