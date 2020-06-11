//
//  AppVersionHistory.swift
//  CoronaContact
//

import Foundation

struct AppVersionHistory: Collection {
    typealias Content = String
    typealias AppVersionHistoryDictionary = [AppVersion: Content]

    var history: AppVersionHistoryDictionary = [
        "2.0": "whats_new_in_2.0.0".localized,
    ]

    lazy var firstVersion: AppVersion = {
        history.keys.sorted(by: <).first!
    }()

    var versions: Set<AppVersion> {
        Set(history.keys)
    }

    // MARK: - Collection Conformance

    typealias Index = AppVersionHistoryDictionary.Index
    typealias SubSequence = AppVersionHistoryDictionary.SubSequence
    typealias Element = AppVersionHistoryDictionary.Element

    var startIndex: Index { history.startIndex }
    var endIndex: Index { history.endIndex }
    func index(after index: Index) -> Index {
        history.index(after: index)
    }

    subscript(position: AppVersionHistoryDictionary.Index) -> Element {
        history[position]
    }
}
