//
//  BatchDownloadService.swift
//  CoronaContact
//

import Foundation
import Resolver

enum BatchDownloadError: Error {
    case noResult
    case cancelled
    case unzip(Error)
    case network(Error)
}

final class BatchDownloadService {
    enum DownloadRequirement {
        case sevenDaysBatchAndDailyBatches
        case onlyFourteenDaysBatch
    }

    @Injected private var networkService: NetworkService

    private lazy var queue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = BatchDownloadConfiguration.maxConcurrentOperationCount
        return queue
    }()

    private var completionHandler: ((Result<[UnzippedBatch], BatchDownloadError>) -> Void)?
    private var unzippedBatches = [UnzippedBatch]()
    private let log = ContextLogger(context: LoggingContext.batchDownload)

    func startBatchDownload(_ downloadRequirement: DownloadRequirement,
                            completionHandler: @escaping (Result<[UnzippedBatch], BatchDownloadError>) -> Void) -> Progress {
        let progress = Progress()

        unzippedBatches = []
        self.completionHandler = completionHandler

        log.debug("Start downloading the exposure keys batch.")

        downloadExposureKeysBatch { [weak self] result in
            guard let self = self else {
                return
            }

            switch result {
            case let .success(batch):
                self.log.debug("Successfully downloaded the exposure keys batch.")

                let downloadOperations = self.downloadFiles(in: batch, downloadRequirement: downloadRequirement)
                let unzipOperations = self.unzipFiles(after: downloadOperations)
                let completeOperation = self.completeBatchDownload(after: unzipOperations)

                let allOperations =
                    downloadOperations +
                    unzipOperations +
                    [completeOperation]

                self.queue.addOperations(allOperations, waitUntilFinished: false)
            case let .failure(error):
                LoggingService.error("Error downloading batch: \(error)", context: .batchDownload)
                completionHandler(.failure(.network(error)))
            }
        }

        progress.cancellationHandler = { [weak self] in
            self?.completionHandler = nil
            self?.queue.cancelAllOperations()
        }

        return progress
    }

    private func downloadExposureKeysBatch(completion: @escaping (Result<ExposureKeysBatch, NetworkError>) -> Void) {
        networkService.downloadExposureKeysBatch(completion: completion)
    }

    private func downloadFiles(in batch: ExposureKeysBatch, downloadRequirement: DownloadRequirement) -> [BatchDownloadOperation] {
        let fullBatchDownloadOperations: [BatchDownloadOperation]
        let dailyBatchesDownloadOperations: [BatchDownloadOperation]

        if downloadRequirement == .sevenDaysBatchAndDailyBatches {
            log.debug("Start downloading the full 7-days batch and the daily batches.")

            fullBatchDownloadOperations = downloadFiles(
                at: batch.fullSevenDaysBatch.filePaths,
                batch: batch.fullSevenDaysBatch,
                batchType: .full
            )
            dailyBatchesDownloadOperations = batch.dailyBatches.flatMap { batch in
                downloadFiles(at: batch.filePaths, batch: batch, batchType: .daily)
            }
        } else {
            log.debug("Start downloading the full 14-days batch.")

            fullBatchDownloadOperations = downloadFiles(
                at: batch.fullFourteenDaysBatch.filePaths,
                batch: batch.fullFourteenDaysBatch,
                batchType: .full
            )
            dailyBatchesDownloadOperations = []
        }

        return fullBatchDownloadOperations + dailyBatchesDownloadOperations
    }

    private func downloadFiles(at paths: [String], batch: Batch, batchType: BatchType) -> [BatchDownloadOperation] {
        paths.map { path in
            let operation = BatchDownloadOperation(path: path, batch: batch, batchType: batchType, networkService: networkService)
            operation.completionBlock = handleCompletion(of: operation)
            return operation
        }
    }

    private func unzipFiles(after operations: [BatchDownloadOperation]) -> [UnzipBatchOperation] {
        operations.map { downloadOperation -> UnzipBatchOperation in
            let operation = UnzipBatchOperation()
            operation.addDependency(downloadOperation)
            operation.completionBlock = handleCompletion(of: operation)

            return operation
        }
    }

    private func completeBatchDownload(after operations: [UnzipBatchOperation]) -> CompleteOperation {
        let completeOperation = CompleteOperation()
        operations.forEach(completeOperation.addDependency)
        completeOperation.completionBlock = handleCompletion(of: completeOperation)

        return completeOperation
    }

    private func handleCompletion<Success>(of operation: AsyncResultOperation<Success, BatchDownloadError>) -> () -> Void {
        // swiftformat:disable:next redundantReturn
        return {
            guard let result = operation.result else {
                self.log.warning("Unexpectedly found no result for \(operation).")
                self.completionHandler?(.failure(.noResult))
                self.queue.cancelAllOperations()
                return
            }

            switch result {
            case .success where operation is CompleteOperation:
                self.log.debug("Successfully completed downloading all batches.")
                self.completionHandler?(.success(self.unzippedBatches))
            case let .success(response) where operation is UnzipBatchOperation && response is UnzippedBatch:
                guard let batch = response as? UnzippedBatch else {
                    assertionFailure()
                    return
                }
                self.unzippedBatches.append(batch)
            case .success:
                break
            case let .failure(error):
                self.queue.cancelAllOperations()
                self.completionHandler?(.failure(error))
                self.removeBatches()
            }
        }
    }

    private func removeBatches() {
        try? FileManager.default.removeItem(at: BatchDownloadConfiguration.DownloadDirectory.batchesURL)
    }
}
