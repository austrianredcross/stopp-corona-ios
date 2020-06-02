//
//  WhatsNewRepository.swift
//  CoronaContact
//

import Foundation

struct AppVersion: Codable, Comparable {

    /// The `2` in `2.5.1`
    let major: Int

    /// The `5` in `2.5.1`
    let minor: Int

    static func < (lhs: AppVersion, rhs: AppVersion) -> Bool {
        lhs.major < rhs.major || lhs.minor < rhs.minor
    }
}
