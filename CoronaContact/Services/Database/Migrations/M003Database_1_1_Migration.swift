//
//  M003Database_1_1Migration.swift
//  CoronaContact
//

import Foundation
import SQLiteMigrationManager
import SQLite

struct M003Database11Migration: Migration {
    var version: Int64 = 2020_04_07__12_00_00__000

    let contactsOLD = Table("handshakes")
    let outMessagesOLD = Table("out_messages")

    let contacts = Table("handshakes_2")
    let outMessages = Table("out_messages_2")
    let inMessages = Table("in_messages")

    let contactId = Expression<Int>("cid")
    let messageId = Expression<Int>("mid")
    let pubkey = Expression<Data>("pubkey")
    let timestamp = Expression<Date>("timestamp")
    let uuid = Expression<String>("uuid")
    let created = Expression<Date>("created")
    let messageType = Expression<String>("type")
    let autoDiscovered = Expression<Bool>("autodiscovered")

    func insertIntoNewOutMessages(_ dba: Connection, _ row: Row) throws {
        try dba.run(outMessages.insert(or: .replace, uuid <- row[outMessagesOLD[uuid]],
                                       messageType <- row[outMessagesOLD[messageType]],
                                       pubkey <- row[contactsOLD[pubkey]],
                                       timestamp <- row[contactsOLD[timestamp]],
                                       created <- row[outMessagesOLD[created]]))
    }

    func createNewOutgoingTable(_ dba: Connection) throws {
        try dba.run(outMessages.create { table in
            table.column(uuid, primaryKey: true)
            table.column(messageType)
            table.column(pubkey)
            table.column(timestamp)
            table.column(created)
        })
    }

    func createNewContactTable(_ dba: Connection) throws {
        try dba.run(contacts.create { table in
            table.column(pubkey, primaryKey: true)
            table.column(timestamp)
            table.column(autoDiscovered)
        })
    }

    func migrateDatabase(_ dba: Connection) throws {

        try createNewOutgoingTable(dba)

        let oldMessagesQuery = outMessagesOLD
                .join(contactsOLD, on: outMessagesOLD[contactId] == contactsOLD[contactId])
                .select(contactsOLD[contactId],
                        contactsOLD[timestamp],
                        contactsOLD[pubkey],
                        outMessagesOLD[messageType],
                        outMessagesOLD[uuid],
                        outMessagesOLD[created])
                .order(created)

        try dba.prepare(oldMessagesQuery).forEach { row in
            try insertIntoNewOutMessages(dba, row)
        }

        try dba.run(outMessagesOLD.drop())

        try createNewContactTable(dba)

        let oldContactsQuery = try dba.prepare(contactsOLD.select(pubkey, timestamp).order(timestamp))
        try oldContactsQuery.forEach { row in
            try dba.run(contacts.insert(or: .replace, pubkey <- row[pubkey], timestamp <- row[timestamp], autoDiscovered <- false))
        }

        try dba.run(contactsOLD.drop())
    }
}
