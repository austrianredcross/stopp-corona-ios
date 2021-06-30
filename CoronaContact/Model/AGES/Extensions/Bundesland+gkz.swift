//
//  Bundesland+gkz.swift
//  CoronaContact
//

import Foundation
extension Bundesland {
    func getGKZRange() throws -> Range<Int> {
        
        switch self {
        case .wien:
            return 900..<1000
        case .vorarlberg:
            return 800..<900
        case .tirol:
            return 700..<800
        case .steiermark:
            return 600..<700
        case .salzburg:
            return 500..<600
        case .oberösterreich:
            return 400..<500
        case .niederösterreich:
            return 300..<400
        case .kärnten:
            return 200..<300
        case .burgenland:
            return 100..<200
        case .österreich:
            return 1..<9
        default: throw AGESError.invalidValidation
        }
    }
}
