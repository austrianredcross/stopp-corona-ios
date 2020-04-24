//
//  SelfTesting+Injection.swift
//  CoronaContact
//

import Foundation
import Resolver

extension Resolver {
    static func registerSelfTestingDependencies() {
        register { SelfTestingFlowController(config: resolve()) }
        register { SelfTestingReportFlowController() }.scope(application)
    }
}
