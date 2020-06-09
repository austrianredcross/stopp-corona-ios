//
//  FileManager+unzipItemWithOverride.swift
//  CoronaContact
//

import Foundation
import ZIPFoundation

extension FileManager {
    func unzipItem(at sourceURL: URL, to destinationURL: URL,
                   skipCRC32: Bool = false, progress: Progress? = nil,
                   preferredEncoding: String.Encoding? = nil,
                   shouldOverride: Bool) throws {
        if shouldOverride, fileExists(atPath: destinationURL.path) {
            try removeItem(at: destinationURL)
        }

        try unzipItem(at: sourceURL, to: destinationURL)
    }
}
