//
//  SicknessCertificateFlowController.swift
//  CoronaContact
//

import ExposureNotification
import Foundation

class SicknessCertificateFlowController: ReportHealthStatusFlowController {
    init() {
        super.init(diagnosisType: .red)
    }
}
