//
//  InfectionInfo.swift
//  CoronaContact
//

import Foundation

// MARK: - PersonalData

struct PersonalData: Codable {

    private enum CodingKeys: String, CodingKey {
        case
        mobileNumber = "mobile-number",
        diagnosisType = "type"
    }

    let mobileNumber: String
    var diagnosisType: DiagnosisType

    init(mobileNumber: String, diagnosisType: DiagnosisType = .red) {
        self.mobileNumber = mobileNumber
        self.diagnosisType = diagnosisType
    }
}
