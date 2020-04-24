import Foundation
import SQLiteMigrationManager
import SQLite

struct M001InitialMigration: Migration {
    var version: Int64 = 2020_04_05__18_00_00__000

    let contacts = Table("handshakes")
    let outMessages = Table("out_messages")
    let inMessages = Table("in_messages")

    let contactId = Expression<Int>("cid")
    let messageId = Expression<Int>("mid")
    let pubkey = Expression<Data>("pubkey")
    let timestamp = Expression<Date>("timestamp")
    let uuid = Expression<String>("uuid")
    let created = Expression<Date>("created")
    let messageType = Expression<String>("type")

    func migrateDatabase(_ dba: Connection) throws {

        try dba.run(contacts.create(ifNotExists: true) { table in
            table.column(contactId, primaryKey: true)
            table.column(pubkey)
            table.column(timestamp)
        })

        try dba.run(inMessages.create(ifNotExists: true) { table in
            table.column(messageId, primaryKey: true)
            table.column(messageType)
            table.column(uuid)
            table.column(timestamp)
            table.column(created)
        })

        try dba.run(outMessages.create(ifNotExists: true) { table in
            table.column(messageId, primaryKey: true)
            table.column(messageType)
            table.column(contactId)
            table.column(uuid)
            table.column(created)
        })

    }
}
