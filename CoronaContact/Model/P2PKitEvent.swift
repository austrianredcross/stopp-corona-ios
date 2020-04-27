//
//  P2PKitEvent.swift
//  CoronaContact
//

import Foundation

struct P2PKitEvent {
    let pubKey: Data
    let signalStrength: Int
    var start: Date
    var end: Date?
}
