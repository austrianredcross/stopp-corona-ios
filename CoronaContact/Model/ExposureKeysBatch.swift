//
//  ExposureKeysBatch.swift
//  CoronaContact
//

import ExposureNotification
import Foundation

struct ExposureKeysBatch: Codable {
    private enum CodingKeys: String, CodingKey {
        case
            fullFourteenDaysBatch = "full_14_batch",
            fullSevenDaysBatch = "full_7_batch",
            dailyBatches = "daily_batches"
    }

    let fullFourteenDaysBatch: Batch
    let fullSevenDaysBatch: Batch
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
    case fullSevenDays
    case fullFourteenDays
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
