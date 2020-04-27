//
//  Response+parseJSON.swift
//  CoronaContact
//

import Foundation
import Moya

private let customDecoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso
    return decoder
}()

extension Response {
    func parseJSON<Type: Decodable>() -> Result<Type, NetworkError> {
        do {
            let value: Type = try map(Type.self, using: customDecoder)
            return .success(value)
        } catch {
            return .failure(.parsingError(error))
        }
    }

    func parseError() -> ErrorResponse? {
        do {
            let value = try map(ErrorResponse.self, using: customDecoder)
            return value
        } catch {
            return nil
        }
    }
}
