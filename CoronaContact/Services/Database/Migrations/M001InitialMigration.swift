//
//  M001InitialMigration.swift
//  CoronaContact
//

import ExposureNotification
import Foundation
import SQLite
import SQLiteMigrationManager

struct M001InitialMigration: Migration {
    var version: Int64 = 20_200_608_100_000

    private struct tracingKeyPassword {
        static let table = Table("key_interval")
        static let timestamp = Expression<Int>("tstamp")
        static let password = Expression<String>("pw")
    }

    func migrateDatabase(_ db: Connection) throws {
        // perform the migration here
        try db.run(tracingKeyPassword.table.create(ifNotExists: true) { table in
            table.column(tracingKeyPassword.timestamp, primaryKey: true)
            table.column(tracingKeyPassword.password)
        })
    }
}
