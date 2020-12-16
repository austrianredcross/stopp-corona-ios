//
//  ContactHealthStatus.swift
//  CoronaContact
//

import Resolver
import UIKit

enum ContactHealthStatus {
    case mixed(quarantineDays: Int? = 0)
    case red(quarantineDays: Int? = 0)
    case yellow(quarantineDays: Int? = 0)

    init?(quarantineDays: Int?) {
        let localStorage: LocalStorage = Resolver.resolve()

        let hadYellowContact = localStorage.lastYellowContact != nil
        let hadRedContact = localStorage.lastRedContact != nil

        switch (hadYellowContact, hadRedContact) {
        case (true, true):
            self = .mixed(quarantineDays: quarantineDays)
        case (false, true):
            self = .red(quarantineDays: quarantineDays)
        case (true, false):
            self = .yellow(quarantineDays: quarantineDays)
        default:
            return nil
        }
    }
}

// MARK: - Notification in the Dashboard

extension ContactHealthStatus {
    var headlineNotification: String {
        "contact_health_status_headline".localized
    }

    var descriptionNotification: String {
        switch self {
        case .mixed:
            return """
            \("contact_health_status_red_warning_description".localized)

            \("contact_health_status_yellow_warning_description".localized)
            """
        case .red:
            return "contact_health_status_red_warning_description".localized
        case .yellow:
            return "contact_health_status_yellow_warning_description".localized
        }
    }

    var quarantineDays: Int? {
        switch self {
        case let .mixed(quarantineDays),
             let .red(quarantineDays),
             let .yellow(quarantineDays):
            return quarantineDays
        }
    }

    var buttonNotification: String {
        if quarantineDays == nil {
            return "general_additional_info".localized
        }

        return "contact_health_status_quarantine_days_button".localized
    }

    var color: UIColor {
        switch self {
        case .mixed, .red:
            return .ccRed
        case .yellow:
            return .ccYellow
        }
    }

    var iconImageNotification: UIImage {
        UIImage(named: icon) ?? UIImage()
    }

    private var icon: String {
        "WarningIconWhite"
    }
}

// MARK: - Contact Sickness Screen

private let dateFormatter = DateFormatter()

private let dateString: (Date) -> String = { date in
    let format = DateFormatter.dateFormat(fromTemplate: "dd.MMMM", options: 0, locale: Locale.current)
    dateFormatter.dateFormat = format
    return dateFormatter.string(from: date)
}

extension ContactHealthStatus {
    var title: String {
        switch self {
        case .mixed:
            return "contact_sickness_mixed_title".localized
        case .red:
            return "contact_sickness_proven_title".localized
        case .yellow:
            return "contact_sickness_warning_title".localized
        }
    }

    var headline: String {
        switch self {
        case .mixed:
            return "contact_sickness_mixed_headline".localized
        case .red:
            return "contact_sickness_proven_headline".localized
        case .yellow:
            return "contact_sickness_warning_headline".localized
        }
    }
    
    var description: String {
        switch self {
        case .mixed:
            return "contact_sickness_proven_description".localized + "\n\n" + "contact_sickness_warning_description".localized
        case .red:
            return "contact_sickness_proven_description".localized
        case .yellow:
            return "contact_sickness_warning_description".localized
        }
    }

    func descriptionOfEncounters(_ warnings: [InfectionWarning]) -> String {
        let red = warnings.filter { $0.type == .red }
        let yellow = warnings.filter { $0.type == .yellow }
        let redWarnings = descriptionForRedWarnings(infections: red)
        let yellowWarnings = descriptionForYellowWarnings(infections: yellow)

        var description = ""

        if let redWarningMessage = redWarnings {
            description += "\(redWarningMessage)"
        }

        if redWarnings != nil, yellowWarnings != nil {
            description += "\n\n"
        }

        if let yellowWarningMessage = yellowWarnings {
            description += "\(yellowWarningMessage)"
        }

        return description
    }

    private func descriptionForRedWarnings(infections: [InfectionWarning]) -> String? {
        guard infections.count > 0 else {
            return nil
        }

        return "contact_sickness_proven_description".localized
    }

    private func descriptionForYellowWarnings(infections: [InfectionWarning]) -> String? {
        guard infections.count > 0 else {
            return nil
        }

        return "contact_sickness_warning_description".localized
    }

    // MARK: Guidelines

    var endOfQuarantine: String? {
        guard let quarantineDays = quarantineDays, let date = Date().addDays(quarantineDays) else {
            return nil
        }

        let endOfQuarantine = dateString(date)
        return endOfQuarantine
    }
    
    var infectedDateString: String? {
        
        let localStorage: LocalStorage = Resolver.resolve()
        
        guard let lastRedContact = localStorage.lastRedContact else { return nil }
        
        return dateString(lastRedContact)
    }

    var guidelines: [Instruction] {
        
        switch self {
        case .red:
            return redGuidelines
        case .yellow:
            return yellowGuidelines
        case .mixed:
            return redGuidelines
        }
    }
    
    var redGuidelines: [Instruction] {
        [
            .init(index: 1, text: String(format: "contact_sickness_guidelines_first".localized, endOfQuarantine!)),
            .init(index: 2, text: String(format: "contact_sickness_guidelines_second".localized, infectedDateString!)),
            .init(index: 3, text: "contact_sickness_guidelines_third".localized),
            .init(index: 4, text: "contact_sickness_guidelines_fourth".localized),
            .init(index: 5, text: "contact_sickness_guidelines_fifth".localized),
            .init(index: 6, text: "contact_sickness_guidelines_sixth".localized),
        ]
    }
    
    var yellowGuidelines: [Instruction] {
        [
            .init(index: 1, text: String(format: "contact_sickness_warning_guidelines_first".localized, endOfQuarantine!)),
            .init(index: 2, text: "contact_sickness_warning_guidelines_second".localized),
            .init(index: 3, text: "contact_sickness_warning_guidelines_third".localized),
            .init(index: 4, text: "contact_sickness_warning_guidelines_fourth".localized),
        ]
    }
}
