//
//  AppConfiguration.swift
//  CoronaContact
//

import Foundation

enum AppConfiguration {
    static let launchScreenDuration: TimeInterval = 1
    static let launchScreenFadeOutAnimationDuration: TimeInterval = 0.3

    static var googleNearbyApiKey: String {
        AppConfiguration.value(for: "GOOGLE_NEARBY_API")
    }

    static var p2pKitApiKey: String {
        AppConfiguration.value(for: "P2P_KIT_API")
    }

    static var apiHostName: String {
        AppConfiguration.value(for: "API_HOST")
    }

    private static func value<T>(for key: String) -> T where T: LosslessStringConvertible {
        guard let object = Bundle.main.object(forInfoDictionaryKey: key) else {
            fatalError("Configuration missing key.")
        }

        switch object {
        case let value as T:
            return value
        case let string as String:
            guard let value = T(string) else { fallthrough }
            return value
        default:
            fatalError("Configuration missing value.")
        }
    }
}
