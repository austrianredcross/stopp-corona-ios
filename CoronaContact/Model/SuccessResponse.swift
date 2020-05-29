//
//  SuccessResponse.swift
//  CoronaContact
//

import Foundation

struct SuccessResponse: Codable {
    let timestamp: Date
    let status: HTTPStatusCode
    let message: String
}
