//
//  Revocation+Injection.swift
//  CoronaContact
//

import Foundation
import Resolver

extension Resolver {
    static func registerRevocationDependencies() {
        register { RevocationFlowController() }.scope(application)
    }
}
