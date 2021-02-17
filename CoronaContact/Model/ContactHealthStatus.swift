//
//  ContactHealthStatus.swift
//  CoronaContact
//

import Resolver
import UIKit

enum ContactHealthStatus: Equatable {
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
    
    static func == (lhs: ContactHealthStatus, rhs: ContactHealthStatus) -> Bool {
        switch (lhs, rhs) {
        case (.red, .red):
            return true
        case (.yellow, .yellow):
            return true
        case (.mixed, .mixed):
            return true
        default:
            return false
        }
    }
}

// MARK: - Notification in the Dashboard

extension ContactHealthStatus {
    
    var primaryHeadlineNotification: String {
        "contact_health_status_headline".localized
    }
    
    var primaryDescriptionNotification: String {
        switch self {
        case .mixed, .red:
            return "contact_health_status_red_warning_description".localized
        case .yellow:
            return "contact_health_status_yellow_warning_description".localized
        }
    }
        var primaryDateNotification: String {
        switch self {
        case .mixed, .red:
            return String(format: "contact_health_status_red_warning_date_text".localized, endOfQuarantine!)
        case .yellow:
            return String(format: "contact_health_status_yellow_warning_date_text".localized, endOfQuarantine!)
        }
    }
    var primaryColorNotification: UIColor {
        switch self {
        case .mixed, .red:
            return .ccRouge
        case .yellow:
            return .ccYellow
        }
    }
    
    var secondaryHeadlineNotification: String {
        "contact_health_status_headline".localized
    }
    
    var secondaryDescriptionNotification: String {
        "contact_health_status_yellow_warning_description".localized
    }
    
    var secondaryColorNotification: UIColor {
        .ccYellow
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
            return .ccRouge
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
    
    var daysSinceLastConact: Int {
        
        let localStorage: LocalStorage = Resolver.resolve()
        let lastRedContact = localStorage.lastRedContact
        let lastYellowContact = localStorage.lastYellowContact
        
        switch self {
        case .red:
            return lastRedContact?.days(until: Date()) ?? 0
        case .yellow:
            return lastYellowContact?.days(until: Date()) ?? 0
        case .mixed:
            return lastRedContact! < lastYellowContact! ? lastRedContact!.days(until: Date()) ?? 0 : lastYellowContact!.days(until: Date()) ?? 0
        }
    }
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
        case .red, .mixed:
            return redGuidelines
        case .yellow:
            return yellowGuidelines
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
