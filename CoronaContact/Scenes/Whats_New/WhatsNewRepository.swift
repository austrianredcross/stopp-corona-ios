//
//  WhatsNewRepository.swift
//  CoronaContact
//

import Resolver
import UIKit

class WhatsNewRepository {
    var appInfo: AppInfo = UIApplication.shared
    var appVersionHistory = AppVersionHistory.whatsNew

    @Persisted(userDefaultsKey: "lastWhatsNewShown", notificationName: .init("lastWhatsNewShownDidChange"), defaultValue: .notPreviouslyInstalled)
    var lastWhatsNewShown: AppVersion

    @Injected
    private var localStorage: LocalStorage

    lazy var currentAppVersion: AppVersion = {
        appInfo.appVersion
    }()

    var allHistoryItems: [WhatsNewContent] {
        appVersionHistory
            .sorted(by: ascendingKeys)
            .map(\.value)
    }

    var newHistoryItems: [WhatsNewContent] {
        appVersionHistory
            .filter { $0.key > lastWhatsNewShown }
            .sorted(by: ascendingKeys)
            .map(\.value)
    }

    var isWhatsNewAvailable: Bool {
        // for the first upgrade to version 2.0 we cannot directly detect if it is a new
        // install or an upgrade since the lastWhatsNewShown value has not been saved in
        // the old version.
        // We assume it's an upgrade if the hasSeenOnboarding flag is set in
        // order to show the history item:
        #warning("Remove this check for the first update after 2.0")
        if lastWhatsNewShown == .notPreviouslyInstalled,
            currentAppVersion == appVersionHistory.firstVersion,
            localStorage.hasSeenOnboarding
        {
            // using a very old version number in order to show what's new for 2.0:
            lastWhatsNewShown = "0.0.1"
            // Note: This will be set to the real current version after What's New has been shown.

            return true
        }

        // Fresh installs should not show app history:
        if lastWhatsNewShown == .notPreviouslyInstalled {
            lastWhatsNewShown = currentAppVersion
            return false
        }
        return appVersionHistory.contains { $0.key > lastWhatsNewShown }
    }

    func markAsSeen() {
        lastWhatsNewShown = currentAppVersion
    }
}

func ascendingKeys<K, V>(_ lhs: (key: K, value: V), _ rhs: (key: K, value: V)) -> Bool
    where K: Comparable
{
    lhs.key < rhs.key
}
