//
//  Questionnaire.swift
//  CoronaContact
//

import Foundation

struct Questionnaire: Codable {
    let questions: [Question]

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let questions = try container.decode([Question].self)
        self.questions = questions
    }
}
