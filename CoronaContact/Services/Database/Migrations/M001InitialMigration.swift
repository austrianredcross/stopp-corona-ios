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

    private struct TracingKeyPassword {
        static let table = Table("key_interval")
        static let timestamp = Expression<Int>("tstamp")
        static let password = Expression<String>("pw")
    }

    func migrateDatabase(_ dba: Connection) throws {
        // delete old tables from version 1.2.x
        let contacts = Table("handshakes_2")
        let outMessages = Table("out_messages_2")
        let inMessages = Table("in_messages")

        try dba.run(contacts.drop(ifExists: true))
        try dba.run(outMessages.drop(ifExists: true))
        try dba.run(inMessages.drop(ifExists: true))

        // create new table for upload passwords
        try dba.run(TracingKeyPassword.table.create(ifNotExists: true) { table in
            table.column(TracingKeyPassword.timestamp, primaryKey: true)
            table.column(TracingKeyPassword.password)
        })
    }
}
