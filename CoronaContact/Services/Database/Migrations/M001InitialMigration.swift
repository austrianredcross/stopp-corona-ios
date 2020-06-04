//
// M001InitialMigration.swift
// CoronaContact
//
// Created by bastian.hoyer on 03.06.20.
//

import Foundation
import SQLiteMigrationManager
import SQLite
import ExposureNotification


struct M001InitialMigration: Migration {
    var version: Int64 = 2020_06_03_16_00_00

    func migrateDatabase(_ db: Connection) throws {
        // perform the migration here
        try db.run(TemporaryExposureKey.table.create(ifNotExists: true) { table in
            table.column(TemporaryExposureKey.key, primaryKey: true)
            table.column(TemporaryExposureKey.password)
            table.column(TemporaryExposureKey.diagnosisType)
            table.column(TemporaryExposureKey.intervalNumber)
            table.column(TemporaryExposureKey.intervalCount)
            table.column(TemporaryExposureKey.transmissionRisk)
        })
    }
}