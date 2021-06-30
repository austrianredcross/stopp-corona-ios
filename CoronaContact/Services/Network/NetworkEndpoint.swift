//
//  NetworkEndpoint.swift
//  CoronaContact
//

import Foundation
import Moya

enum NetworkEndpoint: TargetType {
    case configuration
    case infectionMessages(fromId: String?, addressPrefix: String)
    case requestTan(RequestTan)
    case publish(TracingKeys)
    case downloadKeys
    case downloadBatch(String, DownloadDestination)
    case covidStatistics
}

// MARK: - TargetType Protocol Implementation

extension NetworkEndpoint {
    var baseURL: URL {
        switch self {
        case .requestTan:
            return NetworkConfiguration.smsBaseURL
        case .downloadKeys:
            return NetworkConfiguration.cdnBaseURL
        case .downloadBatch:
            return NetworkConfiguration.cdnHostURL
        case .covidStatistics:
            return NetworkConfiguration.cdnAGESURL
        default:
            return NetworkConfiguration.baseURL
        }
    }

    var path: String {
        switch self {
        case .configuration:
            return "/configuration"
        case .infectionMessages:
            return "/infection-messages"
        case .requestTan:
            return "/request-tan"
        case .publish:
            return "/publish"
        case .downloadKeys:
            return "/index.json"
        case let .downloadBatch(path, _):
            return path
        case .covidStatistics:
            return "/data/JsonData.json"
        }
    }

    var method: Moya.Method {
        switch self {
        case .configuration, .infectionMessages, .downloadKeys, .downloadBatch, .covidStatistics:
            return .get
        case .requestTan, .publish:
            return .post
        }
    }

    var task: Task {
        switch self {
        case .configuration, .downloadKeys:
            return .requestPlain
        case let .infectionMessages(fromId, addressPrefix):
            var parameters = ["addressPrefix": addressPrefix]
            if let fromId = fromId {
                parameters["fromId"] = fromId
            }

            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        case let .requestTan(requestTan):
            return .requestJSONEncodable(requestTan)
        case let .publish(tracingKeys):
            return .requestJSONEncodable(tracingKeys)
        case let .downloadBatch(_, downloadDestination):
            return .downloadDestination(downloadDestination)
        case .covidStatistics:
            return .requestPlain
        }
    }

    var sampleData: Data {
        Data()
    }

    var headers: [String: String]? {
        let authorizationKey: String
        switch self {
        case .requestTan:
            authorizationKey = NetworkConfiguration.smsAuthorizationKey
        default:
            authorizationKey = NetworkConfiguration.authorizationKey
        }

        return [
            NetworkConfiguration.HeaderKeys.authorizationKey: authorizationKey,
            NetworkConfiguration.HeaderKeys.appId: NetworkConfiguration.appId,
            NetworkConfiguration.HeaderKeys.contentType: NetworkConfiguration.HeaderValues.contentType,
        ]
    }
}
