//
//  CovidFaelleTimeline.swift
//  CoronaContact
//

import Foundation

// https://covid19-dashboard.ages.at/data/JsonData.json
// Auto generated Code from: https://app.quicktype.io/

// "CovidFaelle_Timeline"
// 
// "Time":"2020-02-26T00:00:00",
// "Bundesland":"Burgenland",
// "BundeslandID":1,
// "AnzEinwohner":294436,
// "AnzahlFaelle":0,
// "AnzahlFaelleSum":0,
// "AnzahlFaelle7Tage":0,
// "SiebenTageInzidenzFaelle":0.0,
// "AnzahlTotTaeglich":0,
// "AnzahlTotSum":0,
// "AnzahlGeheiltTaeglich":0,
// "AnzahlGeheiltSum":0

// MARK: - CovidFaelleTimeline
struct CovidFaelleTimeline: Codable {
    let time: String
    let bundesland: Bundesland
    let bundeslandID, anzEinwohner, anzahlFaelle, anzahlFaelleSum: Int
    let anzahlFaelle7Tage: Int
    let siebenTageInzidenzFaelle: Double
    let anzahlTotTaeglich, anzahlTotSum, anzahlGeheiltTaeglich, anzahlGeheiltSum: Int

    enum CodingKeys: String, CodingKey {
        case time = "Time"
        case bundesland = "Bundesland"
        case bundeslandID = "BundeslandID"
        case anzEinwohner = "AnzEinwohner"
        case anzahlFaelle = "AnzahlFaelle"
        case anzahlFaelleSum = "AnzahlFaelleSum"
        case anzahlFaelle7Tage = "AnzahlFaelle7Tage"
        case siebenTageInzidenzFaelle = "SiebenTageInzidenzFaelle"
        case anzahlTotTaeglich = "AnzahlTotTaeglich"
        case anzahlTotSum = "AnzahlTotSum"
        case anzahlGeheiltTaeglich = "AnzahlGeheiltTaeglich"
        case anzahlGeheiltSum = "AnzahlGeheiltSum"
    }
}
