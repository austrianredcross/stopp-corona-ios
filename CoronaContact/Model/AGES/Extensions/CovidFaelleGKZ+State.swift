//
//  CovidFaelleGKZ+State.swift
//  CoronaContact
//

import Foundation

extension CovidFaelleGKZ {
    
    var incidenceValue: Double {
        // SOURCE: // https://covid19-dashboard.ages.at/data/JsonData.json
        // Caluclation is from the script2.js from https://covid19-dashboard.ages.at/
        // line 194 -> rel7d: e.AnzahlFaelle7Tage/e.AnzEinwohner*100000
        return (Double(self.anzahlFaelle7Tage) / Double(self.anzEinwohner)) * 100000
    }
    
    func getState() throws -> Bundesland {

        switch self.gkz {
        case 900..<1000:
            return .wien
        case 800..<900:
            return .vorarlberg
        case 700..<800:
            return .tirol
        case 600..<700:
            return .steiermark
        case 500..<600:
            return .salzburg
        case 400..<500:
            return .oberösterreich
        case 300..<400:
            return .niederösterreich
        case 200..<300:
            return .kärnten
        case 100..<200:
            return .burgenland
            
        default: throw AGESError.invalidValidation
        }
    }
}
