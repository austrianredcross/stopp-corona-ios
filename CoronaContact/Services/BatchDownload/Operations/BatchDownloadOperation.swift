//
//  BatchDownloadOperation.swift
//  CoronaContact
//

import Foundation
import Moya

class BatchDownloadOperation: ChainedAsyncResultOperation<Void, DownloadedBatch, BatchDownloadError> {
    private let path: String
    private let batch: Batch
    private let batchType: BatchType
    private let networkService: NetworkService
    private var cancellable: Cancellable?
    private let fileManager = FileManager.default
    private let log = ContextLogger(context: LoggingContext.batchDownload)

    private var destinationFolderURL: URL {
        BatchDownloadConfiguration.DownloadDirectory.zipFolderURL(for: batch.interval, batchType: batchType)
    }

    private var destinationFileURL: URL {
        BatchDownloadConfiguration.DownloadDirectory.zipFileURL(for: batch.interval, batchType: batchType)
    }

    private var downloadDestination: DownloadDestination {
        FileDownloadDestination.makeDestination(for: destinationFileURL)
    }

    init(path: String, batch: Batch, batchType: BatchType, networkService: NetworkService) {
        self.path = path
        self.batch = batch
        self.batchType = batchType
        self.networkService = networkService
    }

    override func main() {
        log.debug("Start downloading batch with type \(batchType) and date \(batch.interval.date) to \(destinationFileURL).")

        cancellable = networkService.downloadBatch(at: path, to: downloadDestination) { [weak self] result in
            guard let self = self else {
                return
            }

            switch result {
            case .success:
                let downloadedBatch = DownloadedBatch(
                    type: self.batchType,
                    interval: self.batch.interval,
                    url: self.destinationFileURL
                )
                self.finish(with: .success(downloadedBatch))
                self.log.debug("""
                Successfully downloaded batch with type \(self.batchType) \
                and date \(self.batch.interval.date) to \(self.destinationFileURL).
                """)
            case let .failure(error):
                self.finish(with: .failure(.network(error)))
                self.log.debug("""
                Failed to download batch with type \(self.batchType) and date \(self.batch.interval.date) \
                to \(self.destinationFileURL) due to an error: \(error).
                """)
            }
        }
    }

    override func cancel() {
        super.cancel(with: .cancelled)

        cancellable?.cancel()
    }
}
