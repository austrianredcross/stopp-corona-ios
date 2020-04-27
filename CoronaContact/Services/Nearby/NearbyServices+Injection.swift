//
//  NearbyServices+Injection.swift
//  CoronaContact
//

import Foundation
import Resolver

extension Resolver {
    public static func registerNearbyServices() {
        register { NearbyService() }
    }
}
