//
//  DailyExposure.swift
//  CoronaContact
//

import Foundation

struct DailyExposure {
    let diagnosisType: DiagnosisType?
    let isSkipped: Bool

    init(diagnosisType: DiagnosisType? = nil, isSkipped: Bool = false) {
        self.diagnosisType = diagnosisType
        self.isSkipped = isSkipped
    }
}
