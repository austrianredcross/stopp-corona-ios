//
//  DatabaseService.swift
//  CoronaContact
//

import Foundation
import Resolver
import SQLite
import SQLiteMigrationManager

class DatabaseService {
    public let dba: Connection!
    public let log = ContextLogger(context: .database)

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

    init(location: DatabaseLocation = .file("db2")) {
        dba = try? Connection(location.location)
        log.debug("Database \(location.location)")
        #if DEBUG || STAGE
            dba!.trace { self.log.debug($0) }
        #endif
        if let dba = dba {
            migrate(dba)
        } else {
            log.error("could not create database")
        }
    }

    private func migrate(_ dba: Connection) {
        let manager = SQLiteMigrationManager(db: dba, migrations: [
            M001InitialMigration(),
        ])

        do {
            if !manager.hasMigrationsTable() {
                log.info("creating migration table")
                try manager.createMigrationsTable()
            }

            if manager.needsMigration() {
                log.info("pending migrations \(manager.pendingMigrations())")
                try manager.migrateDatabase()
            }

            log.info("current migrations: \(manager.appliedVersions())")
        } catch {
            log.error("migration failed: \(error)")
        }
    }

    func periodicCleanup() {
        TracingKeyPassword.periodicCleanup(databaseService: self)
    }
}
