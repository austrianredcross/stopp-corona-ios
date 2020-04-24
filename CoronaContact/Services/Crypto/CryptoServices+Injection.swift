//
//  CryptoServices+Injection.swift
//  CoronaContact
//

import Foundation
import Resolver

extension Resolver {
    public static func registerCryptoServices() {
        register { RSASwiftGenerator() }.scope(application)
        register { CryptoService() }.scope(application)
    }
}
