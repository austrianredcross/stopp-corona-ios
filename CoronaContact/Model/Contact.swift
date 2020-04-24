//
//  Contact.swift
//  CoronaContact
//

import Foundation

struct Contact {
    let timestamp: Date
    let pubKey: Data
    let autoDiscovered: Bool
}

struct ContactUpdate {
    let timestamp: Date
    let pubKey: Data
    let uuid: String?
    let created: Date
}
