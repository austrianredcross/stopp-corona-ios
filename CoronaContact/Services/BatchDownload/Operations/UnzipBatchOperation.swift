//
//  UnzipBatchOperation.swift
//  CoronaContact
//

import Foundation
import ZIPFoundation

class UnzipBatchOperation: ChainedAsyncResultOperation<DownloadedBatch, UnzippedBatch, BatchDownloadError> {
    private let fileManager = FileManager.default
    private let log = ContextLogger(context: LoggingContext.batchDownload)

    var handleUnzippedBatch: ((UnzippedBatch) -> Void)?

    override func main() {
        guard let batch = input else {
            log.warning("Cannot start unzipping the batch, because the batch was not provided as a dependency.")
            return
        }

        let url = batch.url
        let destinationFolderURL = self.destinationFolderURL(for: batch).unzipped
        let fileURLsAtDestination = fileURLs(for: batch, in: destinationFolderURL)

        log.debug("Start unzipping batch with type \(batch.type) and date \(batch.interval.date) to folder: \(url).")

        do {
            try fileManager.createDirectory(at: destinationFolderURL, withIntermediateDirectories: true, attributes: nil)
            try fileManager.unzipItem(at: url, to: destinationFolderURL, shouldOverride: true)

            let unzippedBatch = UnzippedBatch(type: batch.type, interval: batch.interval, urls: fileURLsAtDestination)
            log.debug("""
            Successfully unzipped the contents of batch with type \(batch.type) and date \(batch.interval.date) to: \(fileURLsAtDestination).
            """)
            handleUnzippedBatch?(unzippedBatch)
            finish(with: .success(unzippedBatch))
        } catch {
            log.error("Failed to extract ZIP archive due to an error: \(error)")
            finish(with: .failure(.unzip(error)))
        }
    }

    override func cancel() {
        super.cancel(with: .cancelled)
    }

    private func destinationFolderURL(for batch: DownloadedBatch) -> (root: URL, unzipped: URL) {
        let unzippedFolderURL = BatchDownloadConfiguration.DownloadDirectory.unzippedFolderURL(for: batch.interval, batchType: batch.type)
        let destinationFolderURL = unzippedFolderURL.deletingLastPathComponent()

        return (root: destinationFolderURL, unzipped: unzippedFolderURL)
    }

    private func fileURLs(for batch: DownloadedBatch, in destination: URL) -> [URL] {
        guard let archive = Archive(url: batch.url, accessMode: .read) else {
            log.warning("Could not read the contents of the ZIP archive for batch with type \(batch.type) and date \(batch.interval.date)")
            return []
        }

        var filesURLAtDestination = [URL]()

        for entry in archive.makeIterator() {
            let fileURLAtDestination = destination.appendingPathComponent(entry.path)
            filesURLAtDestination.append(fileURLAtDestination)
        }

        return filesURLAtDestination
    }
}
