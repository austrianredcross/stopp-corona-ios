//
//  AGESRepository+Injection.swift
//  CoronaContact
//

import Foundation
import Resolver

extension Resolver {
    static func registerAGESDependencies() {
        register { AGESRepository() }.scope(application)
    }
}
