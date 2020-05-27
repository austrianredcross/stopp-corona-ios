//
//  DatabaseService.swift
//  CoronaContact
//

import Foundation
import Resolver

enum DatabaseError: Error {
    case general
}

extension Notification.Name {
    static let DatabaseServiceNewSickContact = Notification.Name("dbs_incoming")
    static let DatabaseServiceNewContact = Notification.Name("dbs_contact")
    static let DatabaseSicknessUpdated = Notification.Name("user_sick_status_changed")
}

class DatabaseService {

    func migrate() {
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        let file = "\(path)/db.sqlite3"
    }


    func getIncomingInfectionWarnings(type warningType: InfectionWarningType? = nil, completion: @escaping ([InfectionWarning]) -> Void) {

    }

    func saveOutgoingInfectionWarnings(_ messages: [OutGoingInfectionWarning]) {

    }


    func getContactCount(completion: @escaping (Int) -> Void) {
        completion(0)
    }

    func getContacts(hours: Int? = 0, afterTimestamp lastTs: Date? = nil) -> Swift.Result<[Contact], DatabaseError> {
        .failure(.general)
    }

    func getContactsToUpdate(from type: InfectionWarningType) -> [ContactUpdate] { // this will return all yellow messages that needs update
        []
    }

    func getContactPublicKeys(hours: Int? = 0) -> Swift.Result<[Data], DatabaseError> {
        .failure(.general)
    }

    func saveSicknessState(_ sick: Bool) {
        UserDefaults.standard.hasAttestedSickness = sick
        UserDefaults.standard.attestedSicknessAt = Date()
        NotificationCenter.default.post(name: .DatabaseSicknessUpdated, object: nil)
    }
}
