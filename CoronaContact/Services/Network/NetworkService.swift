//
//  NetworkService.swift
//  CoronaContact
//

import Foundation
import Moya
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
        client = NetworkClient()
        client.handleStatusCode = { [weak self] statusCode in
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

    func requestTan(mobileNumber: String, completion: @escaping (Result<RequestTanResponse, DisplayableError>) -> Void) {
        let requestTan = RequestTan(phoneNumber: mobileNumber)
        client.request(.requestTan(requestTan)) { (result: Result<RequestTanResponse, NetworkError>) in
            switch result {
            case let .failure(.unknownError(statusCode, _, _)):
                completion(.failure(self.parseTanEror(statusCode: statusCode)))
            case .failure:
                completion(.failure(self.parseTanEror(statusCode: nil)))
            case let .success(response):
                completion(.success(response))
            }
        }
    }

    func sendTracingKeys(_ tracingKeys: TracingKeys, completion: @escaping (Result<SuccessResponse, TracingKeysError>) -> Void) {
        client.request(.publish(tracingKeys)) { (result: Result<SuccessResponse, NetworkError>) in
            switch result {
            case let .failure(.unknownError(statusCode, _, _)):
                completion(.failure(self.parseTracingKeysError(statusCode: statusCode)))
            case .failure:
                completion(.failure(self.parseTracingKeysError(statusCode: nil)))
            case let .success(response):
                completion(.success(response))
            }
        }
    }

    func downloadExposureKeysBatch(completion: @escaping (Result<ExposureKeysBatch, NetworkError>) -> Void) {
        client.request(.downloadKeys, completion: completion)
    }

    func downloadBatch(at filePath: String, to destination: @escaping DownloadDestination,
                       completion: @escaping (Result<Void, NetworkError>) -> Void) -> Cancellable {
        client.requestPlain(.downloadBatch(filePath, destination)) { result in
            switch result {
            case .success:
                completion(.success(()))
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}
