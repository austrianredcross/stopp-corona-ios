//
//  RiskCalculationController.swift
//  CoronaContact
//

import ExposureNotification
import Foundation
import Resolver

enum RiskCalculationError: Error {
    case exposureDetectionFailed(Error)
    case exposureInfoUnavailable(Error)
    case cancelled
}

final class RiskCalculationController {
    @Injected private var exposureManager: ExposureManager

    private lazy var queue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    private let log = ContextLogger(context: .riskCalculation)

    func processBatches(_ batches: [UnzippedBatch]) {
        guard let operation = processFullBatch(batches) else {
            return
        }

        operation.completionBlock = { [weak self] in
            guard let result = operation.result else {
                return
            }

            switch result {
            case let .success((lastExposureDate, isEnoughRisk)) where isEnoughRisk:
                self?.processDailyBatches(batches, startingFrom: lastExposureDate)
            case let .success((lastExposureDate, _)):
                self?.log.debug("Exposure at \(lastExposureDate) was not risky enough.")
            case let .failure(error):
                print(error)
            }
        }

        queue.addOperation(operation)
    }

    private func processFullBatch(_ batches: [UnzippedBatch]) -> DetectExposuresOperation? {
        guard let fullBatch = batches.first(where: { $0.type == .full }) else {
            return nil
        }

        let operation = DetectExposuresOperation(diagnosisKeyURLs: fullBatch.urls, exposureManager: exposureManager)
        return operation
    }

    private func processDailyBatches(_ batches: [UnzippedBatch], startingFrom date: Date) {
        let normalizedDate = Calendar.current.startOfDay(for: date)
        let dailyBatches = batches
            .filter { $0.type == .daily }
            .filter { $0.interval.date <= normalizedDate }

        let operations = dailyBatches.map { batch in
            DetectDailyExposuresOperation(diagnosisKeyURLs: batch.urls, exposureManager: exposureManager)
        }

        queue.addOperations(operations, waitUntilFinished: false)
    }
}
