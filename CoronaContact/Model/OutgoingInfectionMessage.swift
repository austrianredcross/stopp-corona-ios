//
//  OutgoingInfectionMessage.swift
//  CoronaContact
//

import Foundation

enum InfectionWarningType: Character {
    case red = "r"
    case yellow = "y"
    case green = "g"
}

struct OutGoingInfectionWarningWithAddressPrefix {
    let outGoingInfectionWarning: OutGoingInfectionWarning
    let addressPrefix: String
}

struct OutGoingInfectionWarning {
    let messageType: InfectionWarningType
    let uuid: String
    let pubkey: Data
    let timestamp: Date
    var base64encoded: String
}
