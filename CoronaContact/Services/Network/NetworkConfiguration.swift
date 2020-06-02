//
//  NetworkConfiguration.swift
//  CoronaContact
//

import Foundation

enum NetworkConfiguration: ConfigurationRetrievable {
    static var baseURL: URL = {
        AppConfiguration.value(for: "API_BASE_URL") { URL(string: $0)! }
    }()

    static var smsBaseURL: URL = {
        AppConfiguration.value(for: "API_SMS_BASE_URL") { URL(string: $0)! }
    }()

    static let authorizationKey: String = {
        let authorizationKey: String = AppConfiguration.value(for: "API_AUTHORIZATION_KEY")
        guard !authorizationKey.isEmpty else {
            fatalError("The `API_AUTHORIZATION_KEY` key in the Info.plist isn't valid.")
        }

        return authorizationKey
    }()

    static let smsAuthorizationKey: String = {
        let authorizationKey: String = AppConfiguration.value(for: "API_SMS_AUTHORIZATION_KEY")
        guard !authorizationKey.isEmpty else {
            fatalError("The `API_SMS_AUTHORIZATION_KEY` key in the Info.plist isn't valid.")
        }

        return authorizationKey
    }()

    static let appId: String = {
        guard let appId = Bundle.main.bundleIdentifier, !appId.isEmpty else {
            fatalError("The `Bundle identifier` key in the Info.plist does not exist or isn't valid.")
        }

        return appId
    }()

    enum HeaderKeys {
        static let contentType = "Content-Type"
        static let authorizationKey = "AuthorizationKey"
        static let appId = "X-AppId"
    }

    enum HeaderValues {
        static let contentType = "application/json"
    }
}
