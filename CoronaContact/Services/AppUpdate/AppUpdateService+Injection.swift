//
//  AppUpdateService+Injection.swift
//  CoronaContact
//

import Foundation
import Resolver

extension Resolver {
    public static func registerAppUpdateServices() {
        register { AppUpdateService() }.scope(application)
    }
}
