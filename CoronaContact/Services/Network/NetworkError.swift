//
//  NetworkError.swift
//  CoronaContact
//

import Foundation

enum NetworkError: Error {

    case notModifiedError
    case parsingError(Error)
    case unknownError(HTTPStatusCode, Error, ErrorResponse? = nil)
}
