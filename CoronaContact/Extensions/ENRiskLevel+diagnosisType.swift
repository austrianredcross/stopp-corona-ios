//
//  ENRiskLevel+diagnosisType.swift
//  CoronaContact
//

import ExposureNotification
import Foundation

extension ENRiskLevel {
    var diagnosisType: DiagnosisType? {
        switch self {
        case 2:
            return .red
        case 5:
            return .yellow
        case 6:
            return .green
        default:
            return nil
        }
    }
}
