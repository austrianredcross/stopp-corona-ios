//
//  WhatsNewRepository.swift
//  CoronaContact
//

import UIKit

typealias AppHistoryItem = String
typealias AppVersionHistory = [AppVersion: AppHistoryItem]
var appVersionHistory: AppVersionHistory = [
    "2.0": "We now use Apple's Exposure Notification framework :)",
]

class WhatsNewRepository {
    
    var appInfo: AppInfo = UIApplication.shared

    @Persisted(userDefaultsKey: "lastWhatsNewShown", notificationName: .init("lastWhatsNewShownDidChange"), defaultValue: .notPreviouslyInstalled)
    var lastWhatsNewShown: AppVersion
    
    lazy var currentAppVersion: AppVersion = {
        appInfo.appVersion
    }()
    
    var newHistoryItems: [AppHistoryItem] {
        appVersionHistory
            .filter { $0.key > lastWhatsNewShown }
            .sorted(by: ascendingKeys)
            .map { $0.value }
    }
    
    var isWhatsNewAvailable: Bool {
        appVersionHistory.contains { $0.key > lastWhatsNewShown }
    }
    
    func currentWhatsNewShown() {
        lastWhatsNewShown = currentAppVersion
    }
}

private func ascendingKeys<K, V>(_ lhs: (key: K, value: V), _ rhs: (key: K, value: V)) -> Bool
where K: Comparable {
    lhs.key < rhs.key
}
