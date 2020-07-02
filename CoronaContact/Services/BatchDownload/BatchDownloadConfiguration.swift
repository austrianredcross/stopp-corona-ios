//
//  BatchDownloadConfiguration.swift
//  CoronaContact
//

import Foundation

enum BatchDownloadConfiguration {
    static let maxConcurrentOperationCount = 5
    static let taskCooldownTime: TimeInterval = 3200
}

extension BatchDownloadConfiguration {
    enum DownloadDirectory {
        static let batchesURL: URL = {
            let directory = FileManager.default.temporaryDirectory
            return directory.appendingPathComponent("batches")
        }()

        static func zipFileURL(for batchInterval: UInt32, batchType: BatchType) -> URL {
            zipFolderURL(for: batchInterval, batchType: batchType)
                .appendingPathComponent("\(batchInterval)-\(batchType).zip")
        }

        static func zipFolderURL(for batchInterval: UInt32, batchType: BatchType) -> URL {
            batchesURL
                .appendingPathComponent("\(batchInterval)-\(batchType)")
                .appendingPathComponent("zipped")
        }

        static func unzippedFolderURL(for batchInterval: UInt32, batchType: BatchType) -> URL {
            batchesURL
                .appendingPathComponent("\(batchInterval)-\(batchType)")
                .appendingPathComponent("unzipped")
        }
    }
}

extension BatchDownloadConfiguration {
    enum Scheduler {
        static let startTime: (hour: Int, minute: Int) = (7, 30)
        static let endTime: (hour: Int, minute: Int) = (21, 30)
        static let intervalInHours = 1
    }
}
