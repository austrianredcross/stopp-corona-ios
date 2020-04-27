import Foundation
import SQLiteMigrationManager
import SQLite

struct M002ScoreMigration: Migration {
    var version: Int64 = 2020_04_06__18_00_00__000

    let p2pkitEvents = Table("p2pkit_events")

    let pID = Expression<Int64>("id")
    let pubkey = Expression<Data>("pubkey")
    let start = Expression<Date>("start")
    let end = Expression<Date?>("end")
    let signalStrength = Expression<Int>("strength")

    func migrateDatabase(_ dba: Connection) throws {
        try dba.run(p2pkitEvents.create(ifNotExists: true) { table in
            table.column(pID, primaryKey: true)
            table.column(pubkey)
            table.column(start)
            table.column(end)
            table.column(signalStrength)
        })
    }
}
