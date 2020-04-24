//
//  JSONDecoder+date.swift
//  CoronaContact
//

import Foundation

extension JSONDecoder.DateDecodingStrategy {
    static var iso: JSONDecoder.DateDecodingStrategy = .formatted(dateFormatters[.iso])
}
