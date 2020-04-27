//
//  DatabaseService+Injection.swift
//  CoronaContact
//

import Foundation
import Resolver

extension Resolver {
    public static func registerDatabaseServices() {
        register { DatabaseService() }.scope(application)
    }
}
