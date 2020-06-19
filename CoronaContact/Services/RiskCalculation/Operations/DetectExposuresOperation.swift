//
//  DetectExposuresOperation.swift
//  CoronaContact
//

import ExposureNotification
import Foundation
import Resolver

class DetectExposuresOperation: AsyncResultOperation<FullExposure, RiskCalculationError> {
    @Injected private var configurationService: ConfigurationService
    @Injected private var exposureManager: ExposureManager

    private let diagnosisKeyURLs: [URL]
    private let batchType: BatchType
    private var progress: Progress?
    private let log = ContextLogger(context: LoggingContext.riskCalculation)

    private var exposureConfiguration: ExposureConfiguration {
        configurationService.currentConfig.exposureConfiguration
    }

    var handleDailyExposure: ((DailyExposure, Date) -> Void)?

    init(diagnosisKeyURLs: [URL], batchType: BatchType) {
        self.diagnosisKeyURLs = diagnosisKeyURLs
        self.batchType = batchType
    }

    override func main() {
        progress = exposureManager.detectExposures(diagnosisKeyURLs: diagnosisKeyURLs) { [weak self] result in
            guard let self = self else {
                return
            }

            switch result {
            case let .success(summary) where summary.lastExposureDate != nil:
                self.handleSummary(summary)
            case .success:
                self.cancel()
            case let .failure(error):
                self.finish(with: .failure(.exposureDetectionFailed(error)))
            }
        }
    }

    override func cancel() {
        super.cancel(with: .cancelled)

        progress?.cancel()
    }

    private func handleSummary(_ summary: ENExposureDetectionSummary) {
        guard let lastExposureDate = summary.lastExposureDate else {
            assertionFailure()
            return
        }

        let isEnoughRisk = self.isEnoughRisk(for: summary)

        switch (batchType, isEnoughRisk) {
        case (.fullSevenDays, _):
            finish(with: .success(.sevenDays(lastExposureDate, isEnoughRisk)))
            return
        case (.fullFourteenDays, false):
            finish(with: .success(.fourteenDays(nil)))
            return
        case (.fullFourteenDays, true):
            break
        case (.daily, _):
            cancel()
            return
        }

        exposureManager.getExposureInfo(summary: summary) { [weak self] result in
            switch result {
            case let .success(exposures):
                self?.handleExposures(exposures, summary: summary, date: lastExposureDate)
            case let .failure(error):
                self?.finish(with: .failure(.exposureInfoUnavailable(error)))
            }
        }
    }

    private func handleExposures(_ exposures: [Exposure], summary: ENExposureDetectionSummary, date: Date) {
        let redExposures = exposures.filter { $0.transmissionRiskLevel.diagnosisType == .red }

        if redExposures.sumTotalRisk >= exposureConfiguration.dailyRiskThreshold {
            log.info("Found a red exposure in \(batchType) batch at date: \(date).")
            let dailyExposure = DailyExposure(diagnosisType: .red)
            reportDailyExposure(dailyExposure, at: date)
            finish(with: .success(.fourteenDays(dailyExposure)))
        } else {
            log.info("Found a yellow exposure in \(batchType) batch at date: \(date).")
            let dailyExposure = DailyExposure(diagnosisType: .yellow)
            reportDailyExposure(dailyExposure, at: date)
            finish(with: .success(.fourteenDays(dailyExposure)))
        }
    }

    private func isEnoughRisk(for summary: ENExposureDetectionSummary) -> Bool {
        summary.totalRiskScore >= exposureConfiguration.dailyRiskThreshold
    }

    private func reportDailyExposure(_ dailyExposure: DailyExposure, at date: Date) {
        handleDailyExposure?(dailyExposure, date)
    }
}
