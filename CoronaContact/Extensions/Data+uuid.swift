//
//  Data+uuid.swift
//  CoronaContact
//

import Foundation

extension Data {
    var uuid: UUID? {
        var bytes = [UInt8](repeating: 0, count: count)
        copyBytes(to: &bytes, count: count * MemoryLayout<UInt8>.size)
        return NSUUID(uuidBytes: bytes) as UUID
    }
}
