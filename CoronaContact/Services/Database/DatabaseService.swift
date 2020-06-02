//
//  DatabaseService.swift
//  CoronaContact
//

import Foundation
import Resolver
import SQLite

class DatabaseService {
    private let dba: Connection?
    private let log = ContextLogger(context: .database)

    enum DatabaseLocation {
        case file(String)
        case inMemory

        var location: Connection.Location {
            switch self {
            case let .file(databaseName):
                let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
                return .uri("\(path)/\(databaseName).sqlite3")
            case .inMemory:
                return .inMemory
            }
        }
    }

    init(location: DatabaseLocation = .file("db")) {
        dba = try? Connection(location.location)
        log.debug("Database \(location.location)")
    }
}
