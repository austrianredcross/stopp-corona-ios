//
//  UIApplication+AppStoreAppId.swift
//  CoronaContact
//

import UIKit

extension UIApplication {
    static var appStoreAppId: String? {
        guard let appStoreAppId = Bundle.main.object(forInfoDictionaryKey: "AppStoreAppID") as? String, !appStoreAppId.isEmpty else {
            return nil
        }

        return appStoreAppId
    }

    static var appStoreAppUrl: URL? {
        guard let appStoreAppId = appStoreAppId,
            let url = URL(string: "https://apps.apple.com/at/app/apple-store/id\(appStoreAppId)") else {
            return nil
        }

        return url
    }

    static var appStoreAppDeepUrl: URL? {
        guard let appStoreAppId = appStoreAppId,
            let url = URL(string: "itms-apps://itunes.apple.com/app/\(appStoreAppId)") else {
            return nil
        }

        return url
    }
}
