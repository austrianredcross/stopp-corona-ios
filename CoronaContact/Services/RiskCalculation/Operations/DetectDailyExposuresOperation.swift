//
//  DetectDailyExposuresOperation.swift
//  CoronaContact
//

import ExposureNotification
import Foundation
import Resolver

class DetectDailyExposuresOperation: ChainedAsyncResultOperation<DailyExposure, DailyExposure, RiskCalculationError> {
    @Injected private var configurationService: ConfigurationService
    @Injected private var exposureManager: ExposureManager

    private let diagnosisKeyURLs: [URL]
    private let date: Date
    private var progress: Progress?
    private let log = ContextLogger(context: LoggingContext.riskCalculation)

    private var exposureConfiguration: ExposureConfiguration {
        configurationService.currentConfig.exposureConfiguration
    }

    var handleDailyExposure: ((DailyExposure, Date) -> Void)?

    init(diagnosisKeyURLs: [URL], date: Date) {
        self.diagnosisKeyURLs = diagnosisKeyURLs
        self.date = date
    }

    override func main() {

        log.debug("Start processing daily batch for date \(date).")

        progress = exposureManager.detectExposures(diagnosisKeyURLs: diagnosisKeyURLs) { [weak self] result in
            guard let self = self else {
                return
            }

            switch result {
            case let .success(summary) where self.isEnoughRisk(for: summary):
                self.exposureManager.getExposureInfo(summary: summary) { [weak self] result in
                    switch result {
                    case let .success(exposures):
                        self?.handleExposures(exposures, summary: summary)
                    case let .failure(error):
                        self?.finish(with: .failure(.exposureInfoUnavailable(error)))
                    }
                }
            case .success:
                let dailyExposure = DailyExposure(diagnosisType: .green)
                self.reportDailyExposure(dailyExposure)
                self.finish(with: .success(dailyExposure))
            case let .failure(error):
                self.finish(with: .failure(.exposureDetectionFailed(error)))
            }
        }
    }

    override func cancel() {
        super.cancel(with: .cancelled)

        progress?.cancel()
    }

    private func isEnoughRisk(for summary: ENExposureDetectionSummary) -> Bool {
        summary.totalRiskScore >= exposureConfiguration.dailyRiskThreshold
    }

    private func handleExposures(_ exposures: [Exposure], summary: ENExposureDetectionSummary) {
        let redExposures = exposures.filter { $0.transmissionRiskLevel.diagnosisType == .red }

        if redExposures.sumTotalRisk >= exposureConfiguration.dailyRiskThreshold {
            log.info("Found a red exposure for the daily batch at date: \(date).")
            let dailyExposure = DailyExposure(diagnosisType: .red)
            reportDailyExposure(dailyExposure)
            finish(with: .success(dailyExposure))
        } else {
            log.info("Found a yellow exposure for the daily batch at date: \(date).")
            let dailyExposure = DailyExposure(diagnosisType: .yellow)
            reportDailyExposure(dailyExposure)
            finish(with: .success(dailyExposure))
        }
    }

    private func reportDailyExposure(_ dailyExposure: DailyExposure) {
        handleDailyExposure?(dailyExposure, date)
    }
}
