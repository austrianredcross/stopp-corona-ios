//
//  SicknessCertificateFlowController.swift
//  CoronaContact
//

import Foundation

class SicknessCertificateFlowController: ReportHealthStatusFlowController {
    init() {
        super.init(diagnosisType: .red)
    }
}
