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

    @Injected private var exposureManager: ExposureManager

    private lazy var queue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    private let log = ContextLogger(context: .riskCalculation)
    private var completionHandler: CompletionHandler?
    private var riskCalculationResult = RiskCalculationResult()

    func processBatches(_ batches: [UnzippedBatch], completionHandler: CompletionHandler) {
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
                self?.log.error(error)
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

        let operations: [DetectDailyExposuresOperation] = dailyBatches.map { batch in
            let operation = DetectDailyExposuresOperation(diagnosisKeyURLs: batch.urls, exposureManager: exposureManager)
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
                self.completionHandler?(.failure(.noResult))
                self.queue.cancelAllOperations()
                return
            }

            switch result {
            case let .success(dailyExposure) where dailyExposure.diagnosisType != nil:
                self.riskCalculationResult[date] = dailyExposure.diagnosisType!
            case .success:
                break
            case let .failure(error):
                self.log.error(error)
                self.completionHandler?(.failure(error))
            }
        }
    }

    private func handleCompletion(of operation: RiskCalculationCompleteOperation) -> () -> Void {
        // swiftformat:disable:next redundantReturn
        return {
            self.completionHandler?(.success(self.riskCalculationResult))
        }
    }
}
