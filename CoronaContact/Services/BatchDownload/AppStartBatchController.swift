//
//  AppStartBatchController.swift
//  CoronaContact
//

import Foundation
import Resolver

final class AppStartBatchController {
    @Injected private var localStorage: LocalStorage
    @Injected private var healthRepository: HealthRepository
    @Injected private var batchDownloadService: BatchDownloadService
    @Injected private var riskCalculationController: RiskCalculationController

    private let log = ContextLogger(context: .batchDownload)

    func startBatchProcessing() {
        guard shouldStartBatchProcessing() else {
            log.debug("Cancelling batch processing on app start, because it already happened within the last hour.")
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

    private func shouldStartBatchProcessing() -> Bool {
        guard let performedBatchProcessingAt = localStorage.performedBatchProcessingAt,
            let oneHourAgo = Calendar.current.date(byAdding: .hour, value: -1, to: Date()) else {
            return true
        }

        return performedBatchProcessingAt < oneHourAgo
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
