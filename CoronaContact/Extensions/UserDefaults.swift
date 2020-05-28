//
//  Userdefaults+keys.swift
//  CoronaContact
//

import UIKit

extension UserDefaults {

    struct Keys {
        static let lastDownloadedMessage        = "last_downloaded_message"
        static let hasSeenOnboarding            = "has_seen_onboarding_2"
        static let agreedToDataPrivacyAt        = "agreed_to_data_privacy_at_2"
        static let notFreshInstalled            = "not_fresh_installed"
        static let isUnderSelfMonitoring        = "is_under_self_monitoring"
        static let isProbablySick               = "is_probably_sick"
        static let isProbablySickAt             = "is_probably_sick_at"
        static let trackingId                   = "tracking_id"
        static let performedSelfTestAt          = "performed_self_test_at"
		static let hideMicrophoneInfoDialog 	= "hide_microphone_info_dialog"
        static let completedVoluntaryQuarantine = "completed_voluntary_quarantine"
        static let completedRequiredQuarantine  = "completed_required_quarantine"
        static let allClearQuarantine           = "all_clear_quarantine"
    }


    var lastDownloadedMessage: Int {
        get {
            integer(forKey: Keys.lastDownloadedMessage)
        }
        set {
            set(newValue, forKey: Keys.lastDownloadedMessage)
        }
    }

    var hasSeenOnboarding: Bool {
        get {
            bool(forKey: Keys.hasSeenOnboarding)
        }
        set {
            set(newValue, forKey: Keys.hasSeenOnboarding)
            if let delegate = UIApplication.shared.delegate as? AppDelegate,
               newValue == true {
                delegate.initializeExternalServices(UIApplication.shared)
            }
        }
    }

    var agreedToDataPrivacyAt: Date? {
        get {
            object(forKey: Keys.agreedToDataPrivacyAt) as? Date
        }
        set {
            set(newValue, forKey: Keys.agreedToDataPrivacyAt)
        }
    }

    var notFreshInstalled: Bool {
        get {
            bool(forKey: Keys.notFreshInstalled)
        }
        set {
            set(newValue, forKey: Keys.notFreshInstalled)
        }
    }

    var isUnderSelfMonitoring: Bool {
        get {
            bool(forKey: Keys.isUnderSelfMonitoring)
        }
        set {
            set(newValue, forKey: Keys.isUnderSelfMonitoring)
        }
    }

    var performedSelfTestAt: Date? {
        get {
            object(forKey: Keys.performedSelfTestAt) as? Date
        }
        set {
            set(newValue, forKey: Keys.performedSelfTestAt)
        }
    }

    var isProbablySick: Bool {
        get {
            bool(forKey: Keys.isProbablySick)
        }
        set {
            set(newValue, forKey: Keys.isProbablySick)
        }
    }

    var isProbablySickAt: Date? {
        get {
            object(forKey: Keys.isProbablySickAt) as? Date
        }
        set {
            set(newValue, forKey: Keys.isProbablySickAt)
        }
    }

    var hideMicrophoneInfoDialog: Bool {
        get {
            bool(forKey: Keys.hideMicrophoneInfoDialog)
        }
        set {
            set(newValue, forKey: Keys.hideMicrophoneInfoDialog)
        }
    }

    var completedVoluntaryQuarantine: Bool {
        get {
            bool(forKey: Keys.completedVoluntaryQuarantine)
        }
        set {
            set(newValue, forKey: Keys.completedVoluntaryQuarantine)
        }
    }

    var completedRequiredQuarantine: Bool {
        get {
            bool(forKey: Keys.completedRequiredQuarantine)
        }
        set {
            set(newValue, forKey: Keys.completedRequiredQuarantine)
        }
    }

    var allClearQuarantine: Bool {
        get {
            bool(forKey: Keys.allClearQuarantine)
        }
        set {
            set(newValue, forKey: Keys.allClearQuarantine)
        }
    }

    var trackingId: String {
        let savedUUID = string(forKey: Keys.trackingId)
        if let savedUUID = savedUUID { return savedUUID }
        let newUUID = UUID().uuidString
        set(newUUID, forKey: Keys.trackingId)
        synchronize()
        return newUUID
    }
}
