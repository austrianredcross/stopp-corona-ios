//
//  ExposureKeysBatch.swift
//  CoronaContact
//

import ExposureNotification
import Foundation

struct ExposureKeysBatch: Codable {
    private enum CodingKeys: String, CodingKey {
        case
            fullBatch = "full_batch",
            dailyBatches = "daily_batches"
    }

    let fullBatch: Batch
    let dailyBatches: [Batch]
}

struct Batch: Codable {
    private enum CodingKeys: String, CodingKey {
        case
            filePaths = "batch_file_paths",
            interval
    }

    let interval: ENIntervalNumber
    let filePaths: [String]
}

enum BatchType: String {
    case full
    case daily
}

struct DownloadedBatch {
    let type: BatchType
    let interval: ENIntervalNumber
    let url: URL
}

struct UnzippedBatch {
    let type: BatchType
    let interval: ENIntervalNumber
    let urls: [URL]
}
