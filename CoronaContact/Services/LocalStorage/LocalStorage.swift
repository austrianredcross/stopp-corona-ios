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

    /// the user declared himself attested sick
    @Persisted(userDefaultsKey: "has_attested_sickness", notificationName: Notification.Name.DatabaseSicknessUpdated, defaultValue: false)
    var hasAttestedSickness: Bool

    /// the date the user declared himself attested sick
    @Persisted(userDefaultsKey: "attested_sickness_at", notificationName: .init("attestedSicknessAt"), defaultValue: nil)
    var attestedSicknessAt: Date?

    /// sets the app in declared sick state, can currently only reset to false by revoke sickness after a accidental sick report
    func saveSicknessState(_ sick: Bool) {
        hasAttestedSickness = sick
        attestedSicknessAt = sick ? Date() : nil
    }

    /// has the user seen the onboarding
    @Persisted(userDefaultsKey: "has_seen_onboarding_2", notificationName: .init("hasSeenOnboarding"), defaultValue: false)
    var hasSeenOnboarding: Bool

    /// the date the user agreed to the data privacy statement in the onboarding
    @Persisted(userDefaultsKey: "agreed_to_data_privacy_at_2", notificationName: .init("agreedToDataPrivacyAt"), defaultValue: nil)
    var agreedToDataPrivacyAt: Date?

    @Persisted(userDefaultsKey: "is_under_self_monitoring", notificationName: .init("isUnderSelfMonitoring"), defaultValue: false)
    var isUnderSelfMonitoring: Bool

    @Persisted(userDefaultsKey: "performed_self_test_at", notificationName: .init("performedSelfTestAt"), defaultValue: nil)
    var performedSelfTestAt: Date?

    @Persisted(userDefaultsKey: "is_probably_sick", notificationName: .init("isProbablySick"), defaultValue: false)
    var isProbablySick: Bool

    @Persisted(userDefaultsKey: "is_probably_sick_at", notificationName: .init("isProbablySickAt"), defaultValue: nil)
    var isProbablySickAt: Date?

    @Persisted(userDefaultsKey: "completed_voluntary_quarantine", notificationName: .init("completedVoluntaryQuarantine"), defaultValue: false)
    var completedVoluntaryQuarantine: Bool

    @Persisted(userDefaultsKey: "completed_required_quarantine", notificationName: .init("completedRequiredQuarantine"), defaultValue: false)
    var completedRequiredQuarantine: Bool

    @Persisted(userDefaultsKey: "all_clear_quarantine", notificationName: .init("allClearQuarantine"), defaultValue: false)
    var allClearQuarantine: Bool
}
