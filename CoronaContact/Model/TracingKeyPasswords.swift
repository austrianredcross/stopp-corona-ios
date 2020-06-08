//
//  TracingKeyPasswords.swift
//  CoronaContact
//

import Foundation
import Resolver
import SQLite

enum TracingKeyPasswordError: Error {
    case databaseFailed
}

struct TracingKeyPassword: Codable {
    static let table = Table("key_interval")
    static let timestamp = Expression<Int>("tstamp")
    static let password = Expression<String>("pw")

    let timestamp: UInt32
    let password: String

    private static func generatePasswordFor(timestamp: Int, db: Connection) throws -> String {
        let password = UUID().uuidString
        let insertQuery = table.insert(self.timestamp <- timestamp, self.password <- password)
        try db.run(insertQuery)
        return password
    }

    static func getPasswordsFor(timestamps: [UInt32]) throws -> [UInt32: String] {
        let databaseService: DatabaseService = Resolver.resolve()
        guard let db = databaseService.dba else {
            throw TracingKeyPasswordError.databaseFailed
        }
        var unhandled = Set(timestamps.map(Int.init))
        var passwords: [UInt32: String] = [:]
        do {
            try db.transaction {
                let selectQuery = table.select([timestamp, password]).filter(unhandled.contains(timestamp))
                for row in try db.prepare(selectQuery) {
                    passwords[UInt32(row[timestamp])] = row[password]
                    unhandled.remove(row[timestamp])
                }
                try unhandled.forEach { timestamp in
                    passwords[UInt32(timestamp)] = try self.generatePasswordFor(timestamp: timestamp, db: db)
                }
            }
        } catch {
            throw TracingKeyPasswordError.databaseFailed
        }
        return passwords
    }
}
