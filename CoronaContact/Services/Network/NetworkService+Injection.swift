//
//  NetworkService+Injection.swift
//  CoronaContact
//

import Foundation
import Resolver

extension Resolver {
    static func registerNetworkServices() {
        register { NetworkService() }.scope(application)
    }
}
