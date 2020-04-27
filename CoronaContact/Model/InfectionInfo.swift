//
//  InfectionInfo.swift
//  CoronaContact
//

import Foundation

// MARK: - InfectionInfo

struct InfectionInfo: Codable {

    private enum CodingKeys: String, CodingKey {
        case
        personalData = "personal-data",
        infectionMessages = "infection-messages",
        authorization
    }

    let personalData: PersonalData
    let infectionMessages: [UploadInfectionMessage]
    let authorization: String
}

// MARK: - PersonalData

struct UploadInfectionMessage: Codable {

    private enum CodingKeys: String, CodingKey {
        case
        message,
        addressPrefix
    }

    let message: String
    let addressPrefix: String
}

// MARK: - PersonalData

struct PersonalData: Codable {

    private enum CodingKeys: String, CodingKey {
        case
        mobileNumber = "mobile-number",
        warning = "type"
    }

    let mobileNumber: String
    var warning: Warning

    init(mobileNumber: String, warning: Warning = .red) {
        self.mobileNumber = mobileNumber
        self.warning = warning
    }
}

// MARK: - Warning

enum Warning: String, Codable {

    case red = "red-warning"
    case yellow = "yellow-warning"
    case green = "green-warning"
}
