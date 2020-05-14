//
//  AppConfiguration.swift
//  CoronaContact
//

import Foundation

enum AppConfiguration: ConfigurationRetrievable {
    static let launchScreenDuration: TimeInterval = 1
    static let launchScreenFadeOutAnimationDuration: TimeInterval = 0.3

    static var appStoreAppId: String {
        AppConfiguration.value(for: "APP_STORE_APP_ID")
    }

    static var googleNearbyApiKey: String {
        AppConfiguration.value(for: "GOOGLE_NEARBY_API")
    }

    static var p2pKitApiKey: String {
        AppConfiguration.value(for: "P2P_KIT_API")
    }

    static var apiHostName: String {
        AppConfiguration.value(for: "API_HOST")
    }

    static var apiSmsHostName: String {
        AppConfiguration.value(for: "API_SMS_HOST")
    }
}
