//
//  RiskCalculationController+Injection.swift
//  CoronaContact
//

import Foundation
import Resolver

extension Resolver {
    static func registerRiskCalculationController() {
        register { RiskCalculationController() }
    }
}
