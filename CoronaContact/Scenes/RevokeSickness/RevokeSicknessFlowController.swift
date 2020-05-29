//
//  RevokeSicknessFlowController.swift
//  CoronaContact
//

import Foundation
import Resolver

class RevokeSicknessFlowController: ReportHealthStatusFlowController {

    init() {
        let diagnosisType: DiagnosisType
        let localStorage: LocalStorage = Resolver.resolve()
        if localStorage.isProbablySick {
            diagnosisType = .yellow
        } else {
            diagnosisType = .green
        }

        super.init(diagnosisType: diagnosisType)
    }
}
