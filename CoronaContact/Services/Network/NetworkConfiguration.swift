//
//  NetworkConfiguration.swift
//  CoronaContact
//

import Foundation

enum NetworkConfiguration {

    static var baseURL: URL = {
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: "ApiBaseUrl") as? String,
            let url = URL(string: urlString) else {
                fatalError("The `ApiBaseUrl` key in the Info.plist does not exist or isn't valid.")
        }

        return url
    }()
    static let authorizationKey: String = {
        guard let authorizationKey = Bundle.main.object(forInfoDictionaryKey: "ApiAuthorizationKey") as? String,
            !authorizationKey.isEmpty else {
                fatalError("The `ApiAuthorizationKey` key in the Info.plist does not exist or isn't valid.")
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
        static let contentType      = "Content-Type"
        static let authorizationKey = "AuthorizationKey"
        static let appId            = "X-AppId"
    }

    enum HeaderValues {
        static let contentType      = "application/json"
    }
}
