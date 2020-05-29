//
//  SelfTestingReportFlowController.swift
//  CoronaContact
//

import Foundation

class SelfTestingReportFlowController: ReportHealthStatusFlowController {
    init() {
        super.init(diagnosisType: .yellow)
    }
}
