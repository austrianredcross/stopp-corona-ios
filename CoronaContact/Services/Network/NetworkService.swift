//
//  NetworkService.swift
//  CoronaContact
//

import Foundation
import Resolver

/**
 Performs network requests

 Can be injected into classes with the `@Injected` property wrapper like so:
 ```
 @Injected var networkService: NetworkService
 ```
 */
final class NetworkService {

    @Injected var appUpdateService: AppUpdateService

    private let client: NetworkClient

    init() {
        self.client = NetworkClient()
        self.client.handleStatusCode = { [weak self] statusCode in
            self?.filterStatusCode(statusCode)
        }
    }

    func fetchConfiguration(completion: @escaping (Result<Data, NetworkError>) -> Void) {
        client.requestPlain(.configuration, completion: completion)
    }

    func fetchInfectionMessages(fromId: String? = nil,
                                addressPrefix: String,
                                completion: @escaping (Result<InfectionMessagesResponse, NetworkError>) -> Void) {
        client.request(.infectionMessages(fromId: fromId, addressPrefix: addressPrefix), completion: completion)
    }

    func sendInfectionInfo(_ infectionInfo: InfectionInfo, completion: @escaping (Result<SuccessResponse, InfectionInfoError>) -> Void) {
        client.request(.infectionInfo(infectionInfo)) { (result: Result<SuccessResponse, NetworkError>) in
            switch result {
            case let .failure((.unknownError(statusCode, _, _))):
                completion(.failure(self.parseInfectionInfoError(statusCode: statusCode)))
            case .failure:
                completion(.failure(self.parseInfectionInfoError(statusCode: nil)))
            case .success(let response):
                completion(.success(response))
            }
        }
    }

    func requestTan(mobileNumber: String, completion: @escaping (Result<RequestTanResponse, DisplayableError>) -> Void) {
        let requestTan = RequestTan(phoneNumber: mobileNumber)
        client.request(.requestTan(requestTan)) { (result: Result<RequestTanResponse, NetworkError>) in
            switch result {
            case let .failure((.unknownError(statusCode, _, _))):
                completion(.failure(self.parseTanEror(statusCode: statusCode)))
            case .failure:
                completion(.failure(self.parseTanEror(statusCode: nil)))
            case .success(let response):
                completion(.success(response))
            }
        }
    }
}
