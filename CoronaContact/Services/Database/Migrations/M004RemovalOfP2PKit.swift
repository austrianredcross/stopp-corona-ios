import Foundation
import SQLiteMigrationManager
import SQLite

struct M004RemovalOfP2PKit: Migration {
    var version: Int64 = 2020_05_15__13_00_00__000

    let p2pkitEvents = Table("p2pkit_events")

    func migrateDatabase(_ dba: Connection) throws {
        try dba.run(p2pkitEvents.drop())
    }
}
