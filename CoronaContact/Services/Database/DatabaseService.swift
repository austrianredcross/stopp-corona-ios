//
//  DatabaseService.swift
//  CoronaContact
//

import Foundation
import Resolver
import SQLite
import SQLiteMigrationManager

enum DatabaseError: Error {
    case general
}

extension Notification.Name {
    static let DatabaseServiceNewSickContact = Notification.Name("dbs_incoming")
    static let DatabaseServiceNewContact = Notification.Name("dbs_contact")
    static let DatabaseSicknessUpdated = Notification.Name("user_sick_status_changed")
}

class DatabaseService {

    enum DatabaseLocation {
        case file(String)
        case inMemory

        var location: Connection.Location {
            switch self {
            case .file(let databaseName):
                let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
                return .uri("\(path)/\(databaseName).sqlite3")
            case .inMemory:
                return .inMemory
            }
        }
    }

    private let dba: Connection?
    private let contacts = Table("handshakes_2")
    private let outMessages = Table("out_messages_2")
    private let inMessages = Table("in_messages")

    private let start = Expression<Date>("start")
    private let end = Expression<Date?>("end")

    private let contactId = Expression<Int>("cid")
    private let messageId = Expression<Int>("mid")
    private let pubkey = Expression<Data>("pubkey")
    private let timestamp = Expression<Date>("timestamp")
    private let uuid = Expression<String>("uuid")
    private let created = Expression<Date>("created")
    private let messageType = Expression<String>("type")
    private let autoDiscovered = Expression<Bool>("autodiscovered")

    @Injected private var notificationService: NotificationService
    private let log = LoggingService.self

    init(location: DatabaseLocation = .file("db")) {
        dba = try? Connection(location.location)
        log.debug("Database \(location.location)", context: .database)
    }

    func migrate() {
        guard let dba = dba else { return }

        let manager = SQLiteMigrationManager(db: dba, migrations: [
            M001InitialMigration(),
            M002ScoreMigration(),
            M003Database11Migration(),
            M004RemovalOfP2PKit()
        ])

        do {
            if !manager.hasMigrationsTable() {
                log.debug("creating migration table", context: .database)
                try manager.createMigrationsTable()
            }

            if manager.needsMigration() {
                log.debug("pending migrations \(manager.pendingMigrations())", context: .database)
                try manager.migrateDatabase()
            }

            log.verbose("current migrations: \(manager.appliedVersions())", context: .database)
        } catch {
            log.error("migration failed: \(error)", context: .database)
        }
    }

    func deleteContacts(before: Date) {
        guard let dba = dba else { return }
        do {
            try dba.run(contacts.filter(timestamp < before).delete())
        } catch {
            log.error("delete failed: \(error)", context: .database)
        }
    }

    func deleteOutgoingMessages(before: Date, type: InfectionWarningType? = nil) {
        guard let dba = dba else { return }
        do {
            var query = outMessages.filter(timestamp < before)
            if let type = type {
                query = query.filter(messageType == String(type.rawValue))
            }
            try dba.run(query.delete())
        } catch {
            log.error("delete failed: \(error)", context: .database)
        }
    }

    func deleteIncomingMessages(before: Date, type: InfectionWarningType? = nil) {
        guard let dba = dba else { return }
        do {
            var query = inMessages.filter(timestamp < before)
            if let type = type {
                query = query.filter(messageType == String(type.rawValue))
            }
            try dba.run(query.delete())
        } catch {
            log.error("delete failed: \(error)", context: .database)
        }
    }

    func getContactByPublicKey(_ pubKey: Data) -> Contact? {
        guard let dba = dba else { return nil }
        do {
            if let contact = try dba.pluck(contacts.filter(pubkey == pubKey)) {
                return Contact(timestamp: contact[timestamp],
                               pubKey: contact[pubkey],
                               autoDiscovered: contact[autoDiscovered])
            }
        } catch {
            log.error("selection failed: \(error)", context: .database)
        }
        return nil
    }

    func updateWarningTypeOnAllOutgoingMessages(type: InfectionWarningType) {
        do {
            try dba?.run(self.outMessages.update(self.messageType <- String(type.rawValue)))
        } catch {
            log.error("update failed: \(error)", context: .database)
        }
    }

    func saveIncomingInfectionWarning(uuid: String, warningType: InfectionWarningType, contactTimeStamp: Date,
                                      completion: ((InfectionWarning?) -> Void)? = nil) {
        DispatchQueue.global(qos: .default).async { [weak self] in
            guard let self = self, let dba = self.dba else { return }
            let infectionWarning = InfectionWarning(type: warningType, timeStamp: contactTimeStamp)
            do {
                let query = self.inMessages.insert(
                        self.messageType <- String(warningType.rawValue),
                        self.uuid <- uuid,
                        self.timestamp <- contactTimeStamp,
                        self.created <- Date()
                )
                try dba.transaction {
                    try dba.run(self.inMessages.filter(self.uuid == uuid).delete())
                    try dba.run(query)
                }
                DispatchQueue.main.async { [weak self] in
                    completion?(infectionWarning)
                    self?.notificationService.showNotificationFor(infectionWarning)
                    NotificationCenter.default.post(name: .DatabaseServiceNewSickContact, object: nil, userInfo: [
                        "messageType": String(warningType.rawValue),
                        "timeStamp": contactTimeStamp
                    ])
                }
            } catch {
                self.log.error("insertion failed: \(error)", context: .database)
                DispatchQueue.main.async { completion?(nil) }
            }
        }
    }

    func getIncomingInfectionWarnings(type warningType: InfectionWarningType? = nil, completion: @escaping ([InfectionWarning]) -> Void) {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self, let dba = self.dba else { return completion([]) }
            do {
                var query = self.inMessages.select(self.messageType, self.timestamp)

                if let type = warningType {
                    query = query.filter(self.messageType == String(type.rawValue))
                }

                let rawData = try dba.prepare(query)

                let data: [InfectionWarning] = rawData.map {
                    let type = InfectionWarningType(rawValue: Character($0[self.messageType]))
                    return InfectionWarning(type: type!, timeStamp: $0[self.timestamp])
                }
                DispatchQueue.main.async { completion(data) }
            } catch {
                self.log.error("query failed: \(error)", context: .database)
                DispatchQueue.main.async { completion([]) }
            }
        }
    }

    func saveOutgoingInfectionWarnings(_ messages: [OutGoingInfectionWarning]) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self, let dba = self.dba else { return }
            do {
                try dba.transaction {
                    for message in messages {
                        if message.messageType == .green { // if message is green just delete old messages
                            try dba.run(self.outMessages.filter(self.uuid == message.uuid).delete())
                        } else {
                            try dba.run(self.outMessages.insert(or: .replace,
                                                                self.uuid <- message.uuid,
                                                                self.messageType <- String(message.messageType.rawValue),
                                                                self.pubkey <- message.pubkey,
                                                                self.timestamp <- message.timestamp,
                                                                self.created <- Date()))
                        }
                    }
                }
            } catch {
                self.log.error("insertion failed: \(error)", context: .database)
            }
        }
    }

    func getHistoryContacts(completion: @escaping (Swift.Result<[History], DatabaseError>) -> Void) {
        guard let dba = dba else { return completion(.failure(.general)) }
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return completion(.failure(.general)) }
            do {
                let history = try dba.prepare(self.contacts.select(self.timestamp, self.autoDiscovered)
                                                      .order(self.timestamp.desc))
                        .map { History(date: $0[self.timestamp], autoDiscovered: $0[self.autoDiscovered]) }
                DispatchQueue.main.async { completion(.success(history)) }
            } catch {
                DispatchQueue.main.async { completion(.failure(.general)) }
            }
        }
    }

    func getContactCount(completion: @escaping (Int) -> Void) {
        guard let dba = dba else { return completion(-1) }
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return completion(-1) }
            do {
                let count = try dba.scalar(self.contacts.count)
                DispatchQueue.main.async { completion(count) }
            } catch {
                DispatchQueue.main.async { completion(-1) }
            }
        }
    }

    func getContacts(hours: Int? = 0, afterTimestamp lastTs: Date? = nil) -> Swift.Result<[Contact], DatabaseError> {
        guard let dba = dba else { return .failure(.general) }
        do {
            var query = contacts.select(pubkey, timestamp, autoDiscovered)
            if let hours = hours,
               hours > 0,
               let date = Calendar.current.date(byAdding: .hour, value: -hours, to: Date()) {
                query = query.filter(timestamp >= date)
            }
            if let lastTs = lastTs {
                query = query.filter(timestamp > lastTs)
            }
            let data = try dba.prepare(query).map {
                Contact(timestamp: $0[timestamp], pubKey: $0[pubkey], autoDiscovered: $0[autoDiscovered])
            }
            return .success(data)
        } catch {
            log.error("getContacts failed: \(error)", context: .database)
            return .failure(.general)
        }
    }

    func getContactsToUpdate(from type: InfectionWarningType) -> [ContactUpdate] { // this will return all yellow messages that needs update
        guard let dba = self.dba else { return [] }

        let selectQuery = outMessages.select(uuid, timestamp, pubkey, created)
                .filter(messageType == String(type.rawValue))
                .order(created)
        do {
            let updates = try dba.prepare(selectQuery).map({ row in
                ContactUpdate(timestamp: row[timestamp], pubKey: row[pubkey], uuid: row[uuid], created: row[created])
            })
            return updates
        } catch {
            return []
        }
    }

    func getContactPublicKeys(hours: Int? = 0) -> Swift.Result<[Data], DatabaseError> {
        guard let dba = dba else { return .failure(.general) }
        do {
            var query = contacts.select(pubkey)
            if let hours = hours,
               let date = Calendar.current.date(byAdding: .hour, value: -hours, to: Date()) {
                query = query.filter(timestamp >= date)
            }
            let data = try dba.prepare(query).map { $0[pubkey] }
            return .success(data)
        } catch {
            log.error("getContactPublicKeys failed: \(error)", context: .database)
            return .failure(.general)
        }
    }

    func saveSicknessState(_ sick: Bool) {
        UserDefaults.standard.hasAttestedSickness = sick
        UserDefaults.standard.attestedSicknessAt = Date()
        NotificationCenter.default.post(name: .DatabaseSicknessUpdated, object: nil)
    }
}
