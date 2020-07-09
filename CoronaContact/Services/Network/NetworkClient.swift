//
//  NetworkClient.swift
//  CoronaContact
//

import Foundation
import Moya

/**
 Low level network interface to Moya.

 Do not use directly, use `NetworkService` instead.
 */
final class NetworkClient {
    typealias PayloadCompletion<Payload> = (_ result: Result<Payload, NetworkError>) -> Void

    var handleStatusCode: ((Int) -> Void)?
    private let provider = MoyaProvider<NetworkEndpoint>(
        session: NetworkSession.session(),
        plugins: [
            NetworkLoggerPlugin(
                configuration: NetworkLoggerPlugin.Configuration(
                    output: { target, items in
                        LoggingService.debug("Network request '\(target)':\n    \(items.joined(separator: "\n    "))")
                    },
                    logOptions: .verbose
                )
            ),
        ]
    )
    private let log = LoggingService.self

    @discardableResult
    func requestPlain(_ target: NetworkEndpoint, completion: @escaping (Result<Data, NetworkError>) -> Void) -> Cancellable {
        provider.request(target) { [weak self] result in
            switch result {
            case let .success(response):
                self?.handleStatusCode?(response.statusCode)

                do {
                    let filteredResponse = try response.filterSuccessfulStatusCodes()
                    completion(.success(filteredResponse.data))
                    self?.log.verbose(response.detailedDebugDescription, context: .network)

                } catch {
                    let statusCode = HTTPStatusCode(statusCode: response.statusCode)
                    if statusCode == .notModified {
                        completion(.failure(.notModifiedError))
                        return
                    }

                    let errorResponse = response.parseError()

                    completion(.failure(.unknownError(statusCode, error, errorResponse)))
                    self?.log.error(response.detailedDebugDescription, context: .network)
                }

            case let .failure(error):
                self?.log.error(error.detailedDebugDescription, context: .network)
                self?.handleStatusCode?(error.errorCode)

                let errorResponse = error.response?.parseError()
                let statusCode = HTTPStatusCode(statusCode: error.errorCode)

                completion(.failure(.unknownError(statusCode, error, errorResponse)))
            }
        }
    }

    @discardableResult
    func request<Payload: Decodable>(_ target: NetworkEndpoint, completion: @escaping (Result<Payload, NetworkError>) -> Void) -> Cancellable {
        provider.request(target) { [weak self] result in
            switch result {
            case let .success(response):

                self?.handleStatusCode?(response.statusCode)

                do {
                    let filteredResponse = try response.filterSuccessfulStatusCodes()
                    completion(.success(try filteredResponse.parseJSON()))
                    self?.log.verbose(response.detailedDebugDescription, context: .network)

                } catch {
                    if let error = error as? DecodingError {
                        self?.log.error("\(response.detailedDebugDescription) DecodingError: \(error)", context: .network)
                        completion(.failure(.parsingError(error)))
                        return
                    }

                    let statusCode = HTTPStatusCode(statusCode: response.statusCode)
                    if statusCode == .notModified {
                        completion(.failure(.notModifiedError))
                        return
                    }

                    let errorResponse = response.parseError()

                    completion(.failure(.unknownError(statusCode, error, errorResponse)))
                    let text = String(data: response.data, encoding: .utf8)
                    self?.log.error("\(response.detailedDebugDescription) data: \(text ?? "<no response data>")", context: .network)
                }

            case let .failure(error):
                self?.log.error(error.detailedDebugDescription, context: .network)
                self?.handleStatusCode?(error.errorCode)

                let errorResponse = error.response?.parseError()
                let statusCode = HTTPStatusCode(statusCode: error.errorCode)

                completion(.failure(.unknownError(statusCode, error, errorResponse)))
            }
        }
    }
}

private extension Response {
    var detailedDebugDescription: String {
        var output = [String]()

        // Response presence check
        if let responseUrl = response?.url {
            output.append("URL: \(responseUrl.absoluteString).")
        } else {
            output.append("Received empty network response.")
        }

        output.append("Status Code: \(statusCode), Data Length: \(data.count)")

        return output.joined(separator: " ")
    }
}

private extension MoyaError {
    var detailedDebugDescription: String {
        if let moyaResponse = response {
            return moyaResponse.detailedDebugDescription
        }

        return errorDescription ?? ""
    }
}
