//
//  BatchDownloadConfiguration.swift
//  CoronaContact
//

import Foundation

enum BatchDownloadConfiguration {
    static let maxConcurrentOperationCount = 5
}

extension BatchDownloadConfiguration {
    enum DownloadDirectory {
        static let batchesURL: URL = {
            let directory = FileManager.default.temporaryDirectory
            return directory.appendingPathComponent("batches")
        }()

        static func zipFileURL(for batchInterval: Int, batchType: BatchType) -> URL {
            zipFolderURL(for: batchInterval, batchType: batchType)
                .appendingPathComponent("\(batchInterval)-\(batchType).zip")
        }

        static func zipFolderURL(for batchInterval: Int, batchType: BatchType) -> URL {
            batchesURL
                .appendingPathComponent("\(batchInterval)-\(batchType)")
                .appendingPathComponent("zipped")
        }

        static func unzippedFolderURL(for batchInterval: Int, batchType: BatchType) -> URL {
            batchesURL
                .appendingPathComponent("\(batchInterval)-\(batchType)")
                .appendingPathComponent("unzipped")
        }
    }
}
