//
//  DetectExposuresOperation.swift
//  CoronaContact
//

import ExposureNotification
import Foundation
import Resolver

class DetectExposuresOperation: AsyncResultOperation<(Date, Bool), RiskCalculationError> {
    @Injected private var configurationService: ConfigurationService

    private let diagnosisKeyURLs: [URL]
    private var progress: Progress?
    private let exposureManager: ExposureManager

    private var exposureConfiguration: ExposureConfiguration {
        configurationService.currentConfig.exposureConfiguration
    }

    init(diagnosisKeyURLs: [URL], exposureManager: ExposureManager) {
        self.diagnosisKeyURLs = diagnosisKeyURLs
        self.exposureManager = exposureManager
    }

    override func main() {
        progress = exposureManager.detectExposures(diagnosisKeyURLs: diagnosisKeyURLs) { [weak self] summary, error in
            guard let self = self else {
                return
            }

            if let error = error {
                self.finish(with: .failure(.exposureDetectionFailed(error)))
                return
            }

            if let summary = summary, let lastExposureDate = summary.lastExposureDate {
                self.finish(with: .success((lastExposureDate, self.isEnoughRisk(for: summary))))
                return
            }

            self.cancel()
        }
    }

    override func cancel() {
        super.cancel(with: .cancelled)

        progress?.cancel()
    }

    private func isEnoughRisk(for summary: ENExposureDetectionSummary) -> Bool {
        summary.maximumRiskScore > exposureConfiguration.dailyRiskThreshold
    }
}
