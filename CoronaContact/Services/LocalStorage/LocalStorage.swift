//
//  LocalStorage.swift
//  CoronaContact
//

import Foundation

class LocalStorage {
    /// the user manually disabled the background handshake
    @Persisted(userDefaultsKey: "backgroundHandShakeDisabled", notificationName: .init("BackgroundHandshakeDisabled"), defaultValue: false)
    var backgroundHandshakeDisabled: Bool

    /// the date the user declared himself attested sick
    @Persisted(userDefaultsKey: "attested_sickness_at", notificationName: .init("attestedSicknessAt"), defaultValue: nil)
    var attestedSicknessAt: Date?
    var hasAttestedSickness: Bool {
        attestedSicknessAt != nil
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

    @Persisted(userDefaultsKey: "is_probably_sick_at", notificationName: .init("isProbablySickAt"), defaultValue: nil)
    var isProbablySickAt: Date?
    var isProbablySick: Bool {
        isProbablySickAt != nil
    }

    @Persisted(userDefaultsKey: "completed_voluntary_quarantine", notificationName: .init("completedVoluntaryQuarantine"), defaultValue: false)
    var completedVoluntaryQuarantine: Bool

    @Persisted(userDefaultsKey: "completed_required_quarantine", notificationName: .init("completedRequiredQuarantine"), defaultValue: false)
    var completedRequiredQuarantine: Bool

    @Persisted(userDefaultsKey: "all_clear_quarantine", notificationName: .init("allClearQuarantine"), defaultValue: false)
    var allClearQuarantine: Bool
}
