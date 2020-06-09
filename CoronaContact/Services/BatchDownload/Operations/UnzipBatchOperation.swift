//
//  UnzipBatchOperation.swift
//  CoronaContact
//

import Foundation
import ZIPFoundation

class UnzipBatchOperation: ChainedAsyncResultOperation<DownloadedBatch, UnzippedBatch, BatchDownloadError> {
    private let fileManager = FileManager.default

    override func main() {
        guard let batch = input else {
            return
        }

        let url = batch.url
        let destinationFolderURL = self.destinationFolderURL(for: batch).unzipped
        let fileURLsAtDestination = fileURLs(for: batch, in: destinationFolderURL)

        do {
            try fileManager.createDirectory(at: destinationFolderURL, withIntermediateDirectories: true, attributes: nil)
            try fileManager.unzipItem(at: url, to: destinationFolderURL, shouldOverride: true)

            let unzippedBatch = UnzippedBatch(type: batch.type, interval: batch.interval, urls: fileURLsAtDestination)
            finish(with: .success(unzippedBatch))
        } catch {
            LoggingService.error("Extraction of ZIP archive failed with error: \(error)", context: .batchDownload)
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
