//
//  HealthStatus.swift
//  CoronaContact
//

import UIKit

enum ContactHealthStatus {

    case mixed(quarantineDays: Int? = 0)
    case red(quarantineDays: Int? = 0)
    case yellow(quarantineDays: Int? = 0)

    init?(basedOn warnings: [InfectionWarning], quarantineDays: Int?) {
        if warnings.count == 0 {
            return nil
        }
        let redCount = warnings.filter { $0.type == .red }.count
        let yellowCount = warnings.filter { $0.type == .yellow }.count

        switch (redCount, yellowCount) {
        case (1..., 1...):
            self = .mixed(quarantineDays: quarantineDays)
        case (1..., 0):
            self = .red(quarantineDays: quarantineDays)
        case (0, 1...):
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
        case .mixed(let quarantineDays),
             .red(let quarantineDays),
             .yellow(let quarantineDays):
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
    dateFormatter.dateFormat = "contact_sickness_date_format".localized
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

    var headlineGuidelines: String {
        "contact_sickness_guidelines_headline".localized
    }

    var endOfQuarantine: String? {
        guard let quarantineDays = quarantineDays, let date = Date().addDays(quarantineDays) else {
            return nil
        }

        let endOfQuarantine = dateString(date)
        return String(format: "contact_sickness_guidelines_quarantine_end".localized, endOfQuarantine)
    }

    var descriptionGuidelines: String {
        "contact_sickness_guidelines_no_public_transport".localized
    }

    var guidelines: [Instruction] {
        [
            .init(index: 1, text: "contact_sickness_guidelines_first".localized),
            .init(index: 2, text: "contact_sickness_guidelines_second".localized),
            .init(index: 3, text: "contact_sickness_guidelines_third".localized),
            .init(index: 4, text: "contact_sickness_guidelines_fourth".localized)
        ]
    }
}
