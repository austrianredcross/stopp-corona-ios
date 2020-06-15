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
            if case .file = self, let filePath = filePath {
                return .uri(filePath)
            }
            return .inMemory
        }

        var filePath: String? {
            if case let .file(databaseName) = self {
                let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
                return "\(path)/\(databaseName).sqlite3"
            }
            return nil
        }
    }

    init(location: DatabaseLocation = .file("db2")) {
        dba = try? Connection(location.location)

        #if DEBUG || STAGE
            dba!.trace { self.log.debug($0) }
        #endif

        // disable iCloud backup for the file
        if let filePath = location.filePath {
            do {
                var fileUrl = URL(fileURLWithPath: filePath)
                if FileManager.default.fileExists(atPath: filePath) {
                    var resourceValues = URLResourceValues()
                    resourceValues.isExcludedFromBackup = true
                    try fileUrl.setResourceValues(resourceValues)
                }
            } catch {
                log.error("failed setting isExcludedFromBackup \(error)")
            }
        }

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
