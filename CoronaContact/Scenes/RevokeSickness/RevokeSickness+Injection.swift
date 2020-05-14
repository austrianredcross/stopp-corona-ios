//
//  RevokeSickness+Injection.swift
//  CoronaContact
//

import Foundation
import Resolver

extension Resolver {
    static func registerRevokeSicknessDependencies() {
        register { RevokeSicknessFlowController() }.scope(application)
    }
}
