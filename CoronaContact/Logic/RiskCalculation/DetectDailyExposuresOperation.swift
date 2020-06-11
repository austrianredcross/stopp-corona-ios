//
//  DetectDailyExposuresOperation.swift
//  CoronaContact
//

import ExposureNotification
import Foundation
import Resolver

class DetectDailyExposuresOperation: ChainedAsyncResultOperation<DailyExposure, DailyExposure, RiskCalculationError> {
    @Injected private var configurationService: ConfigurationService

    private let diagnosisKeyURLs: [URL]
    private var progress: Progress?

    private var exposureConfiguration: ExposureConfiguration {
        configurationService.currentConfig.exposureConfiguration
    }

    let exposureManager: ExposureManager

    init(diagnosisKeyURLs: [URL], exposureManager: ExposureManager) {
        self.diagnosisKeyURLs = diagnosisKeyURLs
        self.exposureManager = exposureManager
    }

    override func main() {
        if let previousExposure = input, previousExposure.diagnosisType == .red || previousExposure.isSkipped {
            finish(with: .success(DailyExposure(isSkipped: true)))
            return
        }

        progress = exposureManager.detectExposures(diagnosisKeyURLs: diagnosisKeyURLs) { [weak self] summary, error in
            guard let self = self else {
                return
            }

            if let error = error {
                self.finish(with: .failure(.exposureDetectionFailed(error)))
                return
            }

            if let summary = summary, self.isEnoughRisk(for: summary) {
                self.exposureManager.getExposureInfo(summary: summary) { [weak self] result in
                    switch result {
                    case let .success(exposures):
                        self?.handleExposures(exposures)
                    case let .failure(error):
                        self?.finish(with: .failure(.exposureInfoUnavailable(error)))
                    }
                }
            } else {
                self.finish(with: .success(DailyExposure(diagnosisType: .green)))
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
            finish(with: .success(DailyExposure(diagnosisType: .red)))
        } else {
            finish(with: .success(DailyExposure(diagnosisType: .yellow)))
        }
    }
}

private extension Array where Element == Exposure {
    var sumTotalRisk: UInt {
        reduce(0) { $0 + UInt($1.totalRiskScore) }
    }
}
