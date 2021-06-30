//
//  CovidFallZahlen.swift
//  CoronaContact
//

import Foundation

// https://covid19-dashboard.ages.at/data/JsonData.json
// Auto generated Code from: https://app.quicktype.io/

// "CovidFallZahlen"
// 
// "Meldedat":"01.04.2020",
// "TestGesamt":7439,
// "MeldeDatum":"2020-04-01T00:00:00",
// "FZHosp":56,
// "FZICU":10,
// "FZHospFree":1267,
// "FZICUFree":85,
// "BundeslandID":5,
// "Bundesland":"Salzburg"

struct CovidFallzahlen: Codable {
    let meldedat: String
    let testGesamt: Int
    let meldeDatum: String
    let fzHosp, fzicu, fzHospFree, fzicuFree: Int
    let bundeslandID: Int
    let bundesland: Bundesland

    enum CodingKeys: String, CodingKey {
        case meldedat = "Meldedat"
        case testGesamt = "TestGesamt"
        case meldeDatum = "MeldeDatum"
        case fzHosp = "FZHosp"
        case fzicu = "FZICU"
        case fzHospFree = "FZHospFree"
        case fzicuFree = "FZICUFree"
        case bundeslandID = "BundeslandID"
        case bundesland = "Bundesland"
    }
}
