//
//  SicknessCertificate+Injection.swift
//  CoronaContact
//

import Foundation
import Resolver

extension Resolver {
    static func registerSicknessCertificateDependencies() {
        register { SicknessCertificateFlowController() }.scope(application)
    }
}
