//
//  CovidFaelleAltersgruppe.swift
//  CoronaContact
//

import Foundation

// https://covid19-dashboard.ages.at/data/JsonData.json
// Auto generated Code from: https://app.quicktype.io/

// "CovidFaelle_Altergruppe"
// 
// "AltersgruppeID":1,
// "Altersgruppe":"<5",
// "Bundesland":"Burgenland",
// "BundeslandID":1,
// "AnzEinwohner":6271,
// "Geschlecht":"M",
// "Anzahl":116,
// "AnzahlGeheilt":106,
// "AnzahlTot":0

// MARK: - CovidFaelleAltersgruppe
struct CovidFaelleAltersgruppe: Codable {
    let altersgruppeID: Int
    let altersgruppe: Altersgruppe
    let bundesland: Bundesland
    let bundeslandID, anzEinwohner: Int
    let geschlecht: Geschlecht
    let anzahl, anzahlGeheilt, anzahlTot: Int

    enum CodingKeys: String, CodingKey {
        case altersgruppeID = "AltersgruppeID"
        case altersgruppe = "Altersgruppe"
        case bundesland = "Bundesland"
        case bundeslandID = "BundeslandID"
        case anzEinwohner = "AnzEinwohner"
        case geschlecht = "Geschlecht"
        case anzahl = "Anzahl"
        case anzahlGeheilt = "AnzahlGeheilt"
        case anzahlTot = "AnzahlTot"
    }
}
