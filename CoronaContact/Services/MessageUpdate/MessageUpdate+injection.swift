//
//  MessageUpdate+injection.swift
//  CoronaContact
//

import Foundation
import Resolver

extension Resolver {
    public static func registerMessageUpdateServices() {
        register { MessageUpdateService() }.scope(application)
    }
}
