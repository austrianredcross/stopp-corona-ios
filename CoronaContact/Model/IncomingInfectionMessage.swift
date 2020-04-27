//
//  InfectionMessage.swift
//  CoronaContact
//

import Foundation

struct IncomingInfectionMessage: Codable {

    private enum CodingKeys: String, CodingKey {
        case identifier = "id", message
    }

    let identifier: Int
    let message: String
}

struct InfectionMessagesResponse: Codable {

    private enum CodingKeys: String, CodingKey {
        case messages = "infection-messages"
    }

    let messages: [IncomingInfectionMessage]
}
