//
//  Answer.swift
//  CoronaContact
//

import Foundation

enum Decision: String, Codable {

    case nextQuestion = "next"
    case suspected = "SUSPICION"
    case selfMonitoring = "SELFMONITORING"
    case hint = "HINT"
}

struct Answer: Codable {

    private enum CodingKeys: String, CodingKey {
        case
        decision = "decission",
        text
    }

    let text: String
    let decision: Decision
}
