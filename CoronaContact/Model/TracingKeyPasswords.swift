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

    private static func generatePasswordFor(timestamp: Int, dba: Connection) throws -> String {
        let password = UUID().uuidString
        let insertQuery = table.insert(self.timestamp <- timestamp, self.password <- password)
        try dba.run(insertQuery)
        return password
    }

    static func getPasswordsFor(timestamps: [UInt32]) throws -> [UInt32: String] {
        let databaseService: DatabaseService = Resolver.resolve()
        guard let dba = databaseService.dba else {
            throw TracingKeyPasswordError.databaseFailed
        }
        var unhandled = Set(timestamps.map(Int.init))
        var passwords: [UInt32: String] = [:]
        do {
            try dba.transaction {
                let selectQuery = table.select([timestamp, password]).filter(unhandled.contains(timestamp))
                for row in try dba.prepare(selectQuery) {
                    passwords[UInt32(row[timestamp])] = row[password]
                    unhandled.remove(row[timestamp])
                }
                try unhandled.forEach { timestamp in
                    passwords[UInt32(timestamp)] = try self.generatePasswordFor(timestamp: timestamp, dba: dba)
                }
            }
        } catch {
            throw TracingKeyPasswordError.databaseFailed
        }
        return passwords
    }
}
