//
//  CovidStatistics.swift
//  CoronaContact
//

import Foundation

//https://covid19-dashboard.ages.at/data/JsonData.json
// Auto generated Code from: https://app.quicktype.io/

//"VersionsNr":"V 2.4.0.0",
//"VersionsDate":"15.04.2021 00:00:00",
//"CreationDate":"15.04.2021 14:02:01",
//"CovidFaelle_Altergruppe": {[CovidFaelle_Altergruppe]},
//"CovidFaelle_Timeline": {[CovidFaelle_Timeline]},
//"CovidFaelle_GKZ": {[CovidFaelle_GKZ]},
//"CovidFallZahlen": {[CovidFallZahlen]}

// MARK: - CovidStatistics
struct CovidStatistics: Codable {
    let versionsNr, versionsDate, creationDate: String
    let covidFaelleAltersgruppe: [CovidFaelleAltersgruppe]
    let covidFaelleTimeline: [CovidFaelleTimeline]
    let covidFaelleGKZ: [CovidFaelleGKZ]
    let covidFallzahlen: [CovidFallzahlen]

    enum CodingKeys: String, CodingKey {
        case versionsNr = "VersionsNr"
        case versionsDate = "VersionsDate"
        case creationDate = "CreationDate"
        case covidFaelleAltersgruppe = "CovidFaelle_Altersgruppe"
        case covidFaelleTimeline = "CovidFaelle_Timeline"
        case covidFaelleGKZ = "CovidFaelle_GKZ"
        case covidFallzahlen = "CovidFallzahlen"
    }
}

enum Altersgruppe: String, Codable {
    case the1524 = "15-24"
    case the2534 = "25-34"
    case the3544 = "35-44"
    case the4554 = "45-54"
    case the5 = "<5"
    case the514 = "5-14"
    case the5564 = "55-64"
    case the6574 = "65-74"
    case the7584 = "75-84"
    case the84 = ">84"
}

enum Bundesland: String, Codable, CaseIterable {
    case alle = "Alle"
    case burgenland = "Burgenland"
    case kärnten = "Kärnten"
    case niederösterreich = "Niederösterreich"
    case oberösterreich = "Oberösterreich"
    case salzburg = "Salzburg"
    case steiermark = "Steiermark"
    case tirol = "Tirol"
    case vorarlberg = "Vorarlberg"
    case wien = "Wien"
    case österreich = "Österreich"
    
    static var getCases: [Bundesland] {
        return Bundesland.allCases.filter({ $0 != .alle })
    }
}

enum Geschlecht: String, Codable {
    case male = "M"
    case woman = "W"
}
