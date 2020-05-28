//
//  LocalStorage.swift
//  CoronaContact
//

import Foundation


extension Notification.Name {
    static let DatabaseSicknessUpdated = Notification.Name("user_sick_status_changed")
}

class LocalStorage {

    /// the user manually disabled the background handshake
    @Persisted(userDefaultsKey: "backgroundHandShakeDisabled", notificationName: .init("BackgroundHandshakeDisabled"), defaultValue: false)
    var backgroundHandshakeDisabled: Bool

    @Persisted(userDefaultsKey: "has_attested_sickness", notificationName: .init("isAttestedSick"), defaultValue: false)
    var hasAttestedSickness: Bool

    @Persisted(userDefaultsKey: "attested_sickness_at", notificationName: Notification.Name.DatabaseSicknessUpdated, defaultValue: nil)
    var attestedSicknessAt: Date?

    func saveSicknessState(_ sick: Bool) {
        hasAttestedSickness = sick
        attestedSicknessAt = sick ? Date() : nil
    }
}
