//
//  RevokeSicknessFlowController.swift
//  CoronaContact
//

import Foundation

class RevokeSicknessFlowController: ReportHealthStatusFlowController {

    init() {
        let diagnosisType: DiagnosisType
        if UserDefaults.standard.isProbablySick {
            diagnosisType = .yellow
        } else {
            diagnosisType = .green
        }

        super.init(diagnosisType: diagnosisType)
    }
}
