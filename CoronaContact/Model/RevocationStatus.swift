//
//  RevocationStatus.swift
//  CoronaContact
//

import UIKit

enum RevocationStatus {
    case completedRequiredQuarantine
    case completedVoluntaryQuarantine
    case allClear

    init?() {
        if UserDefaults.standard.completedVoluntaryQuarantine {
            self = .completedVoluntaryQuarantine
        } else if UserDefaults.standard.completedRequiredQuarantine {
            self = .completedRequiredQuarantine
        } else if UserDefaults.standard.allClearQuarantine {
            self = .allClear
        } else {
            return nil
        }
    }

    var icon: UIImage? {
        guard let iconFileName = iconFileName else {
            return nil
        }

        return UIImage(named: iconFileName)!
    }

    private var iconFileName: String? {
        switch self {
        case .completedVoluntaryQuarantine, .completedRequiredQuarantine:
            return "checkmarkWhite"
        case .allClear:
            return nil
        }
    }

    var color: UIColor? {
        switch self {
        case .completedVoluntaryQuarantine, .completedRequiredQuarantine:
            return .ccGreen
        case .allClear:
            return nil
        }
    }

    var headline: String {
        switch self {
        case .completedRequiredQuarantine:
            return "revocation_required_quarantine_completed_headline".localized
        case .completedVoluntaryQuarantine:
            return "revocation_voluntary_quarantine_completed_headline".localized
        case .allClear:
            return "revocation_all_clear_headline".localized
        }
    }

    var description: String {
        switch self {
        case .completedRequiredQuarantine:
            return "revocation_required_quarantine_completed_description".localized
        case .completedVoluntaryQuarantine:
            return "revocation_voluntary_quarantine_completed_description".localized
        case .allClear:
            return "revocation_all_clear_description".localized
        }
    }

    var primaryActionText: String? {
        switch self {
        case .completedRequiredQuarantine, .completedVoluntaryQuarantine, .allClear:
            return nil
        }
    }

    func clear() {
        UserDefaults.standard.completedVoluntaryQuarantine = false
        UserDefaults.standard.completedRequiredQuarantine = false
        UserDefaults.standard.allClearQuarantine = false
    }
}
