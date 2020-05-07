//
//  ConfigurationRetrievable.swift
//  CoronaContact
//

import Foundation

protocol ConfigurationRetrievable {

    static func value<A>(for key: String) -> A where A: LosslessStringConvertible
    static func value<A, B>(for key: String, _ transform: (A) -> B) -> B where A: LosslessStringConvertible
}

extension ConfigurationRetrievable {
    static func value<A>(for key: String) -> A where A: LosslessStringConvertible {
        guard let object = Bundle.main.object(forInfoDictionaryKey: key) else {
            fatalError("Configuration missing key: \(key).")
        }

        switch object {
        case let value as A:
            return value
        case let string as String:
            guard let value = A(string) else { fallthrough }
            return value
        default:
            fatalError("Configuration missing value for key: \(key).")
        }
    }

    static func value<A, B>(for key: String, _ transform: (A) -> B) -> B where A: LosslessStringConvertible {
        let value: A = Self.value(for: key)
        return transform(value)
    }
}
