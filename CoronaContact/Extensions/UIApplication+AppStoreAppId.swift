//
//  UIApplication+AppStoreAppId.swift
//  CoronaContact
//

import UIKit

extension UIApplication {
    static var appStoreAppUrl: URL? {
        guard let url = URL(string: "https://apps.apple.com/at/app/apple-store/id\(AppConfiguration.appStoreAppId)") else {
            return nil
        }

        return url
    }

    static var appStoreAppDeepUrl: URL? {
        guard let url = URL(string: "itms-apps://itunes.apple.com/app/\(AppConfiguration.appStoreAppId)") else {
            return nil
        }

        return url
    }
}
