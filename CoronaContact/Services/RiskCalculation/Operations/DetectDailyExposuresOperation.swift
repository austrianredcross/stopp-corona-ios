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

    init(diagnosisKeyURLs: [URL], date: Date) {
        self.diagnosisKeyURLs = diagnosisKeyURLs
        self.date = date
    }

    override func main() {
        if let previousExposure = input, previousExposure.diagnosisType == .red || previousExposure.isSkipped {
            log.debug("""
                Skipping risk calculation for date \(date),\
                because the previous date had a diagnosisType of \(String(describing: previousExposure.diagnosisType))\
                or was skipped as well.
            """)
            finish(with: .success(DailyExposure(isSkipped: true)))
            return
        }

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
                        self?.handleExposures(exposures)
                    case let .failure(error):
                        self?.finish(with: .failure(.exposureInfoUnavailable(error)))
                    }
                }
            case .success:
                self.finish(with: .success(DailyExposure(diagnosisType: .green)))
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
        summary.maximumRiskScore > exposureConfiguration.dailyRiskThreshold
    }

    private func handleExposures(_ exposures: [Exposure]) {
        let redExposures = exposures.filter { $0.transmissionRiskLevel.diagnosisType == .red }

        if redExposures.sumTotalRisk > exposureConfiguration.minimumRiskScore {
            log.debug("Found a red exposure for the daily batch at date: \(date).")
            finish(with: .success(DailyExposure(diagnosisType: .red)))
        } else {
            log.debug("Found a yellow exposure for the daily batch at date: \(date).")
            finish(with: .success(DailyExposure(diagnosisType: .yellow)))
        }
    }
}

private extension Array where Element == Exposure {
    var sumTotalRisk: UInt {
        reduce(0) { $0 + UInt($1.totalRiskScore) }
    }
}
