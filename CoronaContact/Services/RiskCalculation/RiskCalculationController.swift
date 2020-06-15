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
    case noResult
}

typealias RiskCalculationResult = [Date: DiagnosisType]

final class RiskCalculationController {
    typealias CompletionHandler = ((Result<RiskCalculationResult, RiskCalculationError>) -> Void)

    private lazy var queue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    private let log = ContextLogger(context: LoggingContext.riskCalculation)
    private var completionHandler: CompletionHandler?
    private var riskCalculationResult = RiskCalculationResult()

    func processBatches(_ batches: [UnzippedBatch], completionHandler: @escaping CompletionHandler) {
        guard let operation = processFullBatch(batches) else {
            return
        }
        self.completionHandler = completionHandler
        log.debug("Start processing full batch.")

        operation.completionBlock = { [weak self] in
            guard let self = self, let result = operation.result else {
                return
            }

            switch result {
            case let .success((lastExposureDate, isEnoughRisk)) where isEnoughRisk:
                self.log.debug("""
                    Successfully processed the full batch which poses a risk.\
                    Start processing daily batches going back from the last exposure date: \(lastExposureDate).
                """)
                self.processDailyBatches(batches, before: lastExposureDate)
            case .success:
                self.completionHandler?(.success(self.riskCalculationResult))
                self.log.debug("Successfully processed the full batch which does not pose a risk.")
            case let .failure(error):
                self.log.error("Failed to process full batch due to an error: \(error)")
            }
        }

        queue.addOperation(operation)
    }

    private func processFullBatch(_ batches: [UnzippedBatch]) -> DetectExposuresOperation? {
        guard let fullBatch = batches.first(where: { $0.type == .full }) else {
            log.warning("Unexpectedly found no full batch.")
            return nil
        }

        return DetectExposuresOperation(diagnosisKeyURLs: fullBatch.urls)
    }

    private func processDailyBatches(_ batches: [UnzippedBatch], before date: Date) {
        let normalizedDate = Calendar.current.startOfDay(for: date)
        let dailyBatches = batches
            .filter { $0.type == .daily }
            .filter { $0.interval.date <= normalizedDate }

        let operations: [DetectDailyExposuresOperation] = dailyBatches.map { batch in
            let operation = DetectDailyExposuresOperation(diagnosisKeyURLs: batch.urls, date: batch.interval.date)
            operation.completionBlock = handleCompletion(of: operation, date: batch.interval.date)
            return operation
        }

        zip(operations, operations.dropFirst()).forEach { lhs, rhs in
            rhs.addDependency(lhs)
        }

        let completeOperation = completeRiskCalculation(after: operations)
        let allOperations = operations + [completeOperation]

        queue.addOperations(allOperations, waitUntilFinished: false)
    }

    private func completeRiskCalculation(after operations: [DetectDailyExposuresOperation]) -> RiskCalculationCompleteOperation {
        let completeOperation = RiskCalculationCompleteOperation()
        operations.forEach(completeOperation.addDependency)
        completeOperation.completionBlock = handleCompletion(of: completeOperation)

        return completeOperation
    }

    private func handleCompletion(of operation: DetectDailyExposuresOperation, date: Date) -> () -> Void {
        // swiftformat:disable:next redundantReturn
        return {
            guard let result = operation.result else {
                self.log.warning("Unexpectedly found no result for \(operation) for the daily batch at date \(date).")
                self.completionHandler?(.failure(.noResult))
                self.queue.cancelAllOperations()
                return
            }

            switch result {
            case let .success(dailyExposure) where dailyExposure.diagnosisType != nil:
                let diagnosisType = dailyExposure.diagnosisType!
                self.log.debug("Successfully processed daily batch at \(date) with diagnosis type: \(diagnosisType).")
                self.riskCalculationResult[date] = diagnosisType
            case .success:
                self.log.debug("Skipping daily batch at \(date), because it doesn't have a diagnosis type.")
            case let .failure(error):
                self.log.error("Failed to process daily batch at \(date) due to an error: \(error)")
                self.completionHandler?(.failure(error))
            }
        }
    }

    private func handleCompletion(of operation: RiskCalculationCompleteOperation) -> () -> Void {
        // swiftformat:disable:next redundantReturn
        return {
            self.log.debug("Successfully completed the risk calculation with result: \(self.riskCalculationResult)")
            self.completionHandler?(.success(self.riskCalculationResult))
        }
    }
}
