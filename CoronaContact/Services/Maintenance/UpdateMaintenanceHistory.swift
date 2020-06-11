//
//  UpdateMaintenanceHistory.swift
//  CoronaContact
//

import Foundation

protocol VersionDictionary: Collection {
    associatedtype Content
    typealias Storage = [AppVersion: Content]
    var history: Storage { get }
}

extension VersionDictionary {
    var firstVersion: AppVersion {
        history.keys.sorted(by: <).first!
    }

    var versions: Set<AppVersion> {
        Set(history.keys)
    }

    // MARK: - Collection Conformance

    var startIndex: Storage.Index { history.startIndex }
    var endIndex: Storage.Index { history.endIndex }
    func index(after index: Storage.Index) -> Storage.Index {
        history.index(after: index)
    }

    subscript(position: Storage.Index) -> Storage.Element {
        history[position]
    }
}

struct UpdateMaintenanceHistory: VersionDictionary {
    typealias Content = MaintenancePerforming
    typealias MaintenanceHistoryDictionary = [AppVersion: Content]

    var history: MaintenanceHistoryDictionary = [
        "2.0": RemoveGoogleDataService(),
    ]
}
