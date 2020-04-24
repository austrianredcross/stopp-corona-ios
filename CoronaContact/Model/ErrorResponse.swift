//
//  ErrorResponse.swift
//  CoronaContact
//

import Foundation

struct ErrorResponse: Codable {

    let timestamp: Date
    let error: String
    let status: HTTPStatusCode
    let message: String
    let path: String
}
