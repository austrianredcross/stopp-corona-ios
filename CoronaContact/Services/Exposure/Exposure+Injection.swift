//
//  Exposure+Injection.swift
//  CoronaContact
//

import Foundation
import Resolver

@available(iOS 13.4, *)
extension Resolver {
    public static func registerExposureServices() {
        register { ExposureManager() }.scope(application)
    }
}
