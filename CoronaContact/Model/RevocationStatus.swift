//
//  RevocationStatus.swift
//  CoronaContact
//

import Resolver
import UIKit

enum RevocationStatus {
    case completedRequiredQuarantine
    case completedVoluntaryQuarantine
    case allClear

    init?() {
        let localStorage: LocalStorage = Resolver.resolve()
        if localStorage.completedVoluntaryQuarantine {
            self = .completedVoluntaryQuarantine
        } else if localStorage.completedRequiredQuarantine {
            self = .completedRequiredQuarantine
        } else if localStorage.allClearQuarantine {
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
        "heartIcon"
    }

    var color: UIColor? {
        .ccGreen
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
    
    var finishText: String {
        switch self {
        case .completedRequiredQuarantine:
            return "revocation_required_quarantine_completed_finish".localized
        case .completedVoluntaryQuarantine:
            return "revocation_voluntary_quarantine_completed_finish".localized
        case .allClear:
            return "revocation_all_clear_finish".localized
        }
    }

    var primaryActionText: String? {
        switch self {
        case .completedRequiredQuarantine, .completedVoluntaryQuarantine, .allClear:
            return nil
        }
    }

    func clear() {
        let localStorage: LocalStorage = Resolver.resolve()
        localStorage.completedVoluntaryQuarantine = false
        localStorage.completedRequiredQuarantine = false
        localStorage.allClearQuarantine = false
        localStorage.wasQuarantined = false
    }
}
