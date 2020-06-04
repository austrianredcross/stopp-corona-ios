//
// UInt32+Value.swift
// CoronaContact
//
// Created by bastian.hoyer on 03.06.20.
//

import Foundation
import SQLite

extension UInt32 : Number, Value {

    public static let declaredDatatype = "INTEGER"

    public static func fromDatatypeValue(_ datatypeValue: UInt32) -> UInt32 {
        datatypeValue
    }

    public var datatypeValue: UInt32 {
        self
    }

}


extension UInt8 : Number, Value {

    public static let declaredDatatype = "INTEGER"

    public static func fromDatatypeValue(_ datatypeValue: UInt8) -> UInt8 {
        datatypeValue
    }

    public var datatypeValue: UInt8 {
        self
    }

}