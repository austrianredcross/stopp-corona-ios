//
//  DetectExposuresOperation.swift
//  CoronaContact
//

import ExposureNotification
import Foundation
import Resolver

class DetectExposuresOperation: AsyncResultOperation<(Date, Bool), RiskCalculationError> {
    @Injected private var configurationService: ConfigurationService
    @Injected private var exposureManager: ExposureManager

    private let diagnosisKeyURLs: [URL]
    private var progress: Progress?

    private var exposureConfiguration: ExposureConfiguration {
        configurationService.currentConfig.exposureConfiguration
    }

    init(diagnosisKeyURLs: [URL]) {
        self.diagnosisKeyURLs = diagnosisKeyURLs
    }

    override func main() {
        progress = exposureManager.detectExposures(diagnosisKeyURLs: diagnosisKeyURLs) { [weak self] result in
            guard let self = self else {
                return
            }

            switch result {
            case let .success(summary) where summary.lastExposureDate != nil:
                self.finish(with: .success((summary.lastExposureDate!, self.isEnoughRisk(for: summary))))
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

    private func isEnoughRisk(for summary: ENExposureDetectionSummary) -> Bool {
        summary.totalRiskScore >= exposureConfiguration.dailyRiskThreshold
    }
}
