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
}
