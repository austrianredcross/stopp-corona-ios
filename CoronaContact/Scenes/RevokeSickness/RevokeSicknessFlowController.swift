//
//  RevokeSicknessFlowController.swift
//  CoronaContact
//

import Foundation
import Resolver

class RevokeSicknessFlowController: ReportHealthStatusFlowController {
    private var localStorage: LocalStorage = Resolver.resolve()

    init() {
        let diagnosisType: DiagnosisType

        // We handle a wrong attested sickness revocation here. So if the user was previously 'probably sick', the new
        // state will also be 'probably sick'; otherwise we tell others we are healthy
        if localStorage.isProbablySick {
            diagnosisType = .yellow
        } else {
            diagnosisType = .green
        }

        super.init(diagnosisType: diagnosisType)
    }
}
