//
//  p2pkit+Injection.swift
//  CoronaContact
//

import Foundation
import Resolver

extension Resolver {
    public static func registerP2pkitServices() {
        register { P2PKitService() }.scope(application)
    }
}
