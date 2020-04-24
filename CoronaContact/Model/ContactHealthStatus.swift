//
//  HealthStatus.swift
//  CoronaContact
//

import UIKit

enum PointsOfContact {

    case single
    case multiple(Int)
}

enum ContactHealthStatus {

    case mixed(red: PointsOfContact, yellow: PointsOfContact?, quarantineDays: Int? = 0)
    case yellow(PointsOfContact, quarantineDays: Int? = 0)

    init?(basedOn warnings: [InfectionWarning], quarantineDays: Int?) {
        if warnings.count == 0 {
            return nil
        }
        let redCount = warnings.filter { $0.type == .red }.count
        let yellowCount = warnings.filter { $0.type == .yellow }.count

        switch (redCount, yellowCount) {
        case (1, 1):
            self = .mixed(red: .single, yellow: .single, quarantineDays: quarantineDays)
        case (1, 2...):
            self = .mixed(red: .single, yellow: .multiple(yellowCount), quarantineDays: quarantineDays)
        case (2..., 1):
            self = .mixed(red: .multiple(redCount), yellow: .single, quarantineDays: quarantineDays)
        case (2..., 2...):
            self = .mixed(red: .multiple(redCount), yellow: .multiple(yellowCount), quarantineDays: quarantineDays)
        case (2..., 0):
            self = .mixed(red: .multiple(redCount), yellow: nil, quarantineDays: quarantineDays)
        case (1, 0):
            self = .mixed(red: .single, yellow: nil, quarantineDays: quarantineDays)
        case (0, 1):
            self = .yellow(.single, quarantineDays: quarantineDays)
        case (0, 2...):
            self = .yellow(.multiple(yellowCount), quarantineDays: quarantineDays)
        default:
            return nil
        }
    }
}

// MARK: - Notification in the Dashboard

extension ContactHealthStatus {

    var headlineNotification: String {
        switch self {
        case .mixed(.single, _, _):
            return "health_status_red_warning_single_contact_headline".localized
        case .mixed(.multiple, _, _):
            return "health_status_red_warning_multiple_contacts_headline".localized
        case .yellow(.single, _):
            return "health_status_yellow_warning_single_contact_headline".localized
        case .yellow(.multiple, _):
            return "health_status_yellow_warning_multiple_contact_headline".localized
        }
    }

    var descriptionNotification: String {
        switch self {
        case .mixed(.single, .single, _):
            return """
            \("health_status_red_warning_single_contact_description".localized)

            \("health_status_yellow_warning_single_contact_description".localized)
            """
        case .mixed(.single, .multiple(let yellowCount), _):
            return """
            \("health_status_red_warning_single_contact_description".localized)

            \(String(format: "health_status_yellow_warning_multiple_contact_description".localized, yellowCount))
            """
        case .mixed(.multiple(let redCount), .single, _):
            return """
            \(String(format: "health_status_red_warning_multiple_contacts_description".localized, redCount))

            \("health_status_yellow_warning_single_contact_description".localized)
            """
        case .mixed(.multiple(let redCount), .multiple(let yellowCount), _):
            return """
            \(String(format: "health_status_red_warning_multiple_contacts_description".localized, redCount))

            \(String(format: "health_status_yellow_warning_multiple_contact_description".localized, yellowCount))
            """
        case .mixed(.single, _, _):
            return "health_status_red_warning_single_contact_description".localized
        case .mixed(.multiple(let redCount), _, _):
            return String(format: "health_status_red_warning_multiple_contacts_description".localized, redCount)
        case .yellow(.single, _):
            return "health_status_yellow_warning_single_contact_description".localized
        case .yellow(.multiple(let count), _):
            return String(format: "health_status_yellow_warning_multiple_contact_description".localized, count)
        }
    }

    var quarantineDays: Int? {
        switch self {
        case .mixed(_, _, let quarantineDays):
            return quarantineDays
        case .yellow(_, let quarantineDays):
            return quarantineDays
        }
    }

    var buttonNotification: String {
        switch self {
        case .mixed(.single, _, let quarantineDays):
            if quarantineDays == nil {
                return "general_additional_info".localized
            } else {
                return "health_status_red_warning_single_contact_button".localized
            }
        case .mixed(.multiple, _, let quarantineDays):
            if quarantineDays == nil {
                return "general_additional_info".localized
            } else {
                return "health_status_red_warning_multiple_contacts_button".localized
            }
        case .yellow(.single, let quarantineDays):
            if quarantineDays == nil {
                return "general_additional_info".localized
            } else {
                return "health_status_yellow_warning_single_contact_button".localized
            }
        case .yellow(.multiple, let quarantineDays):
            if quarantineDays == nil {
                return "general_additional_info".localized
            } else {
                return "health_status_yellow_warning_multiple_contact_button".localized
            }
        }
    }

    var color: UIColor {
        switch self {
        case .mixed:
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
            return "contact_sickness_proven_title".localized
        case .yellow:
            return "contact_sickness_warning_title".localized
        }
    }

    var headline: String {
        switch self {
        case .mixed(.single, _, _):
            return "contact_sickness_proven_headline_single".localized
        case .mixed(.multiple(let count), _, _):
            return String(format: "contact_sickness_proven_headline_multiple".localized, count)
        case .yellow(.single, _):
            return "contact_sickness_warning_headline_single".localized
        case .yellow(.multiple(let count), _):
            return String(format: "contact_sickness_warning_headline_multiple".localized, count)
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

        var descriptionText = ""
        var handshakeText = ""

        switch infections.count {
        case 1:
            descriptionText = String(
                format: "contact_sickness_proven_description_single".localized,
                "contact_sickness_proven_description_attested".localized
            )
            handshakeText = "contact_sickness_handshake_single".localized
        default:
            descriptionText = String(
                format: "contact_sickness_proven_description_multiple".localized,
                infections.count,
                "contact_sickness_proven_description_attested".localized
            )
            handshakeText = "contact_sickness_handshake_multiple".localized
        }

        let handshakes = descriptionForHandshakes(infections: infections).joined(separator: "\n")

        let handshakesText = """
        \(handshakeText)
        \(handshakes)
        """

        return """
        \(descriptionText)

        \(handshakesText)
        """
    }

    private func descriptionForYellowWarnings(infections: [InfectionWarning]) -> String? {
        guard infections.count > 0 else {
            return nil
        }

        var descriptionText = ""
        var handshakeText = ""

        switch infections.count {
        case 1:
            descriptionText = String(
                format: "contact_sickness_warning_description_single".localized,
                "contact_sickness_warning_explanation".localized
            )
            handshakeText = "contact_sickness_handshake_single".localized
        default:
            descriptionText = String(
                format: "contact_sickness_warning_description_multiple".localized,
                infections.count,
                "contact_sickness_warning_explanation".localized
            )
            handshakeText = "contact_sickness_handshake_multiple".localized
        }

        let handshakes = descriptionForHandshakes(infections: infections).joined(separator: "\n")

        let handshakesText = """
        \(handshakeText)
        \(handshakes)
        """

        return """
        \(descriptionText)

        \(handshakesText)
        """
    }

    private func descriptionForHandshakes(infections: [InfectionWarning]) -> [String] {
        infections.map { $0.handshakeDescription }
    }

    // MARK: Guidelines

    var headlineGuidelines: String {
        switch self {
        case .mixed:
            return "contact_sickness_proven_guidelines_headline".localized
        case .yellow:
            return "contact_sickness_warning_guidelines_headline".localized
        }
    }

    var endOfQuarantine: String? {
        var days: Int?

        switch self {
        case .mixed(_, _, quarantineDays: let quarantineDays):
            days = quarantineDays
        case .yellow(_, quarantineDays: let quarantineDays):
            days = quarantineDays
        }

        guard let quarantineDays = days, let date = Date().addDays(quarantineDays) else {
            return nil
        }

        let endOfQuarantine = dateString(date)
        return String(format: "contact_sickness_proven_guidelines_quarantine_end".localized, endOfQuarantine)
    }

    var descriptionGuidelines: String {
        switch self {
        case .mixed:
            return "contact_sickness_proven_guidelines_no_public_transport".localized
        case .yellow:
            return "contact_sickness_warning_guidelines_no_public_transport".localized
        }
    }

    var guidelines: [Instruction] {
        switch self {
        case .mixed:
            return [
                .init(index: 1, text: "contact_sickness_proven_guidelines_first".localized),
                .init(index: 2, text: "contact_sickness_proven_guidelines_second".localized),
                .init(index: 3, text: "contact_sickness_proven_guidelines_third".localized),
                .init(index: 4, text: "contact_sickness_proven_guidelines_fourth".localized)
            ]
        case .yellow:
            return [
                .init(index: 1, text: "contact_sickness_warning_guidelines_first".localized),
                .init(index: 2, text: "contact_sickness_warning_guidelines_second".localized),
                .init(index: 3, text: "contact_sickness_warning_guidelines_third".localized),
                .init(index: 4, text: "contact_sickness_warning_guidelines_fourth".localized)
            ]
        }
    }
}
