//
//  CryptoServices+Injection.swift
//  CoronaContact
//

import Foundation
import Resolver

extension Resolver {
    public static func registerCryptoServices() {
        register { CryptoService() }.scope(application)
    }
}
