//
//  CryptoService.swift
//  CoronaContact
//

import Foundation
import Resolver

enum CryptoError: Error {
    case general
}

class CryptoService {

    func createRevokeInfectionMessages(to type: InfectionWarningType) -> Result<[OutGoingInfectionWarningWithAddressPrefix], CryptoError> {
        .failure(.general)
    }

    func createInfectionWarnings(type: InfectionWarningType) -> Result<[OutGoingInfectionWarningWithAddressPrefix], CryptoError> {
        .failure(.general)
    }

    func parseIncomingInfectionWarnings(_ warnings: [IncomingInfectionMessage], completion: @escaping ((Result<Int, CryptoError>) -> Void)) {
        completion(.failure(.general))
    }

    public func getMyPublicKeyPrefix() -> String? {
        nil
    }

}
