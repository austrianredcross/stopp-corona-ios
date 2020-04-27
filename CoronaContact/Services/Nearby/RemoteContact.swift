//
//  RemoteContact.swift
//  CoronaContact
//

import Foundation

struct RemoteContact: Equatable, Codable {
    var name: String
    let key: Data
    var removed: Bool = false
    var saved: Bool = false
    var selected: Bool = false
    var timestamp: Date
    var automaticDiscovered: Bool

    init(name: String, key: Data, automaticDiscovered: Bool = false, timestamp: Date? = nil) {
        self.name = name
        self.key = key
        self.timestamp = timestamp ?? Date()
        self.automaticDiscovered = automaticDiscovered
    }
}
