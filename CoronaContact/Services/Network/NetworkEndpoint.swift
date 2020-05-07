//
//  NetworkEndpoint.swift
//  CoronaContact
//

import Foundation
import Moya

enum NetworkEndpoint: TargetType {
    case configuration
    case infectionMessages(fromId: String?, addressPrefix: String)
    case infectionInfo(InfectionInfo)
    case requestTan(RequestTan)
}

// MARK: - TargetType Protocol Implementation
extension NetworkEndpoint {
    var baseURL: URL {
        switch self {
        case .requestTan:
            return NetworkConfiguration.smsBaseURL
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
        case .infectionInfo:
            return "/infection-info"
        case .requestTan:
            return "/request-tan"
        }
    }

    var method: Moya.Method {
        switch self {
        case .configuration, .infectionMessages:
            return .get
        case .requestTan:
            return .post
        case .infectionInfo:
            return .put
        }
    }

    var task: Task {
        switch self {
        case .configuration:
            return .requestPlain
        case let .infectionMessages(fromId, addressPrefix):
            var parameters = ["addressPrefix": addressPrefix]
            if let fromId = fromId {
                parameters["fromId"] = fromId
            }

            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        case let .infectionInfo(infectionInfo):
            return .requestCustomJSONEncodable(infectionInfo, encoder: JSONEncoder.withApiDateFormat)
        case let .requestTan(requestTan):
            return .requestJSONEncodable(requestTan)
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
            NetworkConfiguration.HeaderKeys.contentType: NetworkConfiguration.HeaderValues.contentType
        ]
    }
}
