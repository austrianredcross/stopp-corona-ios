//
//  UserHealthStatus.swift
//  CoronaContact
//

import Resolver
import UIKit

private let dateFormatter = DateFormatter()

private let dateString: (Date) -> String = { date in
    let format = DateFormatter.dateFormat(fromTemplate: "dd.MMMM", options: 0, locale: Locale.current)
    dateFormatter.dateFormat = format
    return dateFormatter.string(from: date)
}

enum UserHealthStatus: Equatable {
    case isHealthy
    case isUnderSelfMonitoring
    case isProbablySick(quarantineDays: Int = 0)
    case hasAttestedSickness

    /// most severe state wins
    init(quarantineDays: Int? = nil) {
        let quarantineDays = quarantineDays ?? 0
        let localStorage: LocalStorage = Resolver.resolve()

        if localStorage.hasAttestedSickness {
            self = .hasAttestedSickness
        } else if localStorage.isProbablySick {
            self = .isProbablySick(quarantineDays: quarantineDays)
        } else if localStorage.isUnderSelfMonitoring {
            self = .isUnderSelfMonitoring
        } else {
            self = .isHealthy
        }
    }
    
    static func == (lhs: UserHealthStatus, rhs: UserHealthStatus) -> Bool {
        switch (lhs, rhs) {
        case (.isHealthy, .isHealthy):
            return true
        case (.isUnderSelfMonitoring, .isUnderSelfMonitoring):
            return true
        case (.isProbablySick, .isProbablySick):
            return true
        case (.hasAttestedSickness, .hasAttestedSickness):
            return true
        default:
            return false
        }
    }

    var canUploadMissingKeys: Bool {
        let localStorage: LocalStorage = Resolver.resolve()
        guard let missingKeysAt = localStorage.missingUploadedKeysAt else {
            return false
        }
        return missingKeysAt.startOfDayUTC() < Date().startOfDayUTC()
    }

    func canRevokeProvenSickness() -> Bool {
        let localStorage: LocalStorage = Resolver.resolve()
        guard let attestedSicknessAt = localStorage.attestedSicknessAt else {
            return false
        }
        return attestedSicknessAt.addDays(2)! >= Date().startOfDayUTC()
    }

    var icon: UIImage {
        UIImage(named: iconFileName)!
    }

    var color: UIColor? {
        switch self {
        case .isProbablySick, .isUnderSelfMonitoring:
            return .ccYellow
        case .hasAttestedSickness:
            return .ccRouge
        default:
            return nil
        }
    }

    private var iconFileName: String {
        switch self {
        case .isHealthy:
            return "checkmarkWhite"
        case .isProbablySick, .isUnderSelfMonitoring, .hasAttestedSickness:
            return "WarningIconWhite"
        }
    }

    var headline: String {
        switch self {
        case .isHealthy:
            return ""
        case .isUnderSelfMonitoring:
            return "self_testing_symptoms_headline".localized
        case .isProbablySick:
            return "self_testing_suspicion_headline".localized
        case .hasAttestedSickness:
            return "sickness_certificate_attest_headline".localized
        }
    }

    var description: String {
        switch self {
        case .isHealthy:
            return ""
        case .isUnderSelfMonitoring:
            return "self_testing_symptoms_description".localized
        case .isProbablySick:
            return "self_testing_suspicion_description".localized
        case .hasAttestedSickness:
            return "sickness_certificate_attest_description".localized
        }
    }
    
    var dateText: String {
        switch self {
        case .isHealthy:
            return ""
        case  .isUnderSelfMonitoring:
            return ""
        case .isProbablySick:
            return "self_testing_suspicion_date_date".localized
        case .hasAttestedSickness:
            return "sickness_certificate_attest_date_text".localized
        }
    }

    var quarantineDays: Int? {
        if case let .isProbablySick(quarantineDays) = self {
            return quarantineDays
        }
        
        return nil
    }

    var endOfQuarantine: String? {
        guard let quarantineDays = quarantineDays, let date = Date().addDays(quarantineDays) else {
            return nil
        }

        let endOfQuarantine = dateString(date)
        return String(format: "suspicion_guidelines_quarantine_end".localized, endOfQuarantine)
    }

    var primaryActionText: String {
        switch self {
        case .isHealthy:
            return ""
        case .isUnderSelfMonitoring:
            return "general_additional_info".localized
        case .isProbablySick:
            return "self_testing_suspicion_button".localized
        case .hasAttestedSickness:
            return "sickness_certificate_attest_button".localized
        }
    }

    var secondaryActionText: String? {
        switch self {
        case .hasAttestedSickness:
            return canRevokeProvenSickness() ? "sickness_certificate_attest_button_revoke".localized : "sickness_certificate_attest_button_report_healthy".localized
        case .isUnderSelfMonitoring:
            return "self_testing_symptoms_secondary_button".localized
        case .isProbablySick:
            return "self_testing_suspicion_recovery_button".localized
        default:
            return nil
        }
    }

    var tertiaryActionText: String? {
        switch self {
        case .isProbablySick:
            return "self_testing_suspicion_report_sickness_button".localized
        default:
            return nil
        }
    }
}
