//
//  DetectDailyExposuresOperation.swift
//  CoronaContact
//

import ExposureNotification
import Foundation

class DetectDailyExposuresOperation: AsyncResultOperation<[Exposure], RiskCalculationError> {
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

            if let summary = summary {
                self.exposureManager.getExposureInfo(summary: summary) { [weak self] result in
                    switch result {
                    case let .success(exposures):
                        self?.handleExposures(exposures)
                    case let .failure(error):
                        self?.finish(with: .failure(.exposureInfoUnavailable(error)))
                    }
                }
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
        return true
    }

    private func handleExposures(_ exposures: [Exposure]) {
        #warning("TODO: decide based on 'red' and 'yellow' exposures if the day is 'red' or 'yellow'")

        finish(with: .success(exposures))
    }
}
