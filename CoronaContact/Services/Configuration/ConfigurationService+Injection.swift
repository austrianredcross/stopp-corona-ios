//
//  ConfigurationService+Injection.swift
//  CoronaContact
//

import Foundation
import Resolver

extension Resolver {
    public static func registerConfigurationServices() {
        register { ConfigurationService() }.scope(application)
    }
}
