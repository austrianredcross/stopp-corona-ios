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
        if localStorage.isProbablySick {
            diagnosisType = .yellow
        } else {
            diagnosisType = .green
        }

        super.init(diagnosisType: diagnosisType)
    }
}
