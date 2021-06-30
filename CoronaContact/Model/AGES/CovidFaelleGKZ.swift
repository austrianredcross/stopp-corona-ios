//
//  CovidFaelleGKZ.swift
//  CoronaContact
//

import Foundation

// https://covid19-dashboard.ages.at/data/JsonData.json
// Auto generated Code from: https://app.quicktype.io/

// "CovidFaelle_GKZ"
//
// "Bezirk":"Eisenstadt(Stadt)",
// "GKZ":101,
// "AnzEinwohner":14816,
// "Anzahl":905,
// "AnzahlTot":11,
// "AnzahlFaelle7Tage":25

// MARK: - CovidFaelleGKZ
struct CovidFaelleGKZ: Codable {
    let bezirk: String
    let gkz, anzEinwohner, anzahl, anzahlTot: Int
    let anzahlFaelle7Tage: Int

    enum CodingKeys: String, CodingKey {
        case bezirk = "Bezirk"
        case gkz = "GKZ"
        case anzEinwohner = "AnzEinwohner"
        case anzahl = "Anzahl"
        case anzahlTot = "AnzahlTot"
        case anzahlFaelle7Tage = "AnzahlFaelle7Tage"
    }
}
