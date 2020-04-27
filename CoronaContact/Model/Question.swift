//
//  Question.swift
//  CoronaContact
//

import Foundation

struct Question: Codable {

    let title: String
    let questionText: String
    let answers: [Answer]
}
