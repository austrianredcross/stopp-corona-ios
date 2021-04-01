//
//  CoreDataService+Injection.swift
//  CoronaContact
//

import Foundation
import Resolver

extension Resolver {
    public static func registerCoreDataService() {
        register { CoreDataSerivce() }.scope(application)
    }
}
