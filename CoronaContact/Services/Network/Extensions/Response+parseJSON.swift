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
    func parseJSON<Type: Decodable>() throws -> Type {
        try map(Type.self, using: customDecoder)
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
