//
//  TracingKeyPassword.swift
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
    static let interval = Expression<Int>("tstamp")
    static let password = Expression<String>("pw")

    let timestamp: UInt32
    let password: String

    private static func generatePasswordFor(interval: Int, dba: Connection) throws -> String {
        let password = UUID().uuidString
        let insertQuery = table.insert(self.interval <- interval, self.password <- password)
        try dba.run(insertQuery)
        return password
    }

    static func getPasswordsFor(intervals: [UInt32]) throws -> [UInt32: String] {
        let databaseService: DatabaseService = Resolver.resolve()
        guard let dba = databaseService.dba else {
            throw TracingKeyPasswordError.databaseFailed
        }
        var unhandled = Set(intervals.map(Int.init))
        var passwords: [UInt32: String] = [:]
        do {
            try dba.transaction {
                let selectQuery = table.select([interval, password]).filter(unhandled.contains(interval))
                for row in try dba.prepare(selectQuery) {
                    passwords[UInt32(row[interval])] = row[password]
                    unhandled.remove(row[interval])
                }
                try unhandled.forEach { timestamp in
                    passwords[UInt32(timestamp)] = try self.generatePasswordFor(interval: timestamp, dba: dba)
                }
            }
        } catch {
            throw TracingKeyPasswordError.databaseFailed
        }
        return passwords
    }

    static func periodicCleanup(databaseService: DatabaseService) {
        // remove intervals that are older than 15 days
        let deleteBeforeInterval = Int(Date().addDays(-15)!.timeIntervalSince1970 / 600)
        _ = try? databaseService.dba.run(table.filter(interval < deleteBeforeInterval).delete())
    }
}
