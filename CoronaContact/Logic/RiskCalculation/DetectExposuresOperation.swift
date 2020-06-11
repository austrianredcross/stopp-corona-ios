//
//  DetectExposuresOperation.swift
//  CoronaContact
//

import ExposureNotification
import Foundation

class DetectExposuresOperation: AsyncResultOperation<(Date, Bool), RiskCalculationError> {
    private let diagnosisKeyURLs: [URL]
    private var progress: Progress?

    let exposureManager: ExposureManager

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
        #warning("TODO: Determine if there is enough risk to warrant the processing")
        true
    }
}
