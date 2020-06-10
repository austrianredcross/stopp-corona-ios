//
//  Logic+Injection.swift
//  CoronaContact
//

import Foundation
import Resolver

extension Resolver {
    public static func registerLogicControllers() {
        register { HealthStateController() }.scope(application)
    }
}
