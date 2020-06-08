//
//  ExposureKeysBatch.swift
//  CoronaContact
//

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

    let interval: Int
    let filePaths: [String]
}

enum BatchType {
    case full
    case daily
}

struct DownloadedBatch {
    let type: BatchType
    let interval: Int
    let url: URL
}

struct UnzippedBatch {
    let type: BatchType
    let interval: Int
    let urls: [URL]
}
