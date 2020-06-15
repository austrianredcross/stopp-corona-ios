//
//  AppVersionHistory.swift
//  CoronaContact
//

import Foundation

typealias WhatsNewContent = String
typealias MaintenanceTasks = HistoryItems<[MaintenancePerforming]>

enum AppVersionHistory {
    static let whatsNew = HistoryItems<WhatsNewContent>([
        "2.0": "whats_new_in_2.0.0".localized,
    ])

    static let maintenanceTasks = MaintenanceTasks([
        "2.0": [
            RemoveGoogleData(),
            RemoveObsoleteUserDefaults(),
        ],
    ])
}

struct HistoryItems<Content>: Collection {
    typealias AppVersionHistoryDictionary = [AppVersion: Content]

    let history: AppVersionHistoryDictionary

    init(_ history: [AppVersion: Content]) {
        self.history = history
    }

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
