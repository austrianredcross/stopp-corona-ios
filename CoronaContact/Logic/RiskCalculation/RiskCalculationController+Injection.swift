//
//  RiskCalculationController+Injection.swift
//  CoronaContact
//

import Foundation

extension Resolver {
    static func registerRiskCalculationController() {
        register { RiskCalculationController() }
    }
}
