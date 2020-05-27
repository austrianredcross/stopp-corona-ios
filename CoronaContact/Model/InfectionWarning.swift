//
//  InfectionWarning.swift
//  CoronaContact
//

import Foundation

private let dateFormatter = DateFormatter()

private let dateString: (Date) -> String = { date in
    dateFormatter.dateFormat = "contact_sickness_date_format".localized
    return dateFormatter.string(from: date)
}
private let timeString: (Date) -> String = { date in
    dateFormatter.dateFormat = "contact_sickness_time_format".localized
    return dateFormatter.string(from: date)
}

struct InfectionWarning {
    let type: InfectionWarningType
    let timeStamp: Date
}

struct ParsedInfectionWarning {
    let type: InfectionWarningType
    let timeStamp: Date
    let uuid: UUID
}

private extension Date {
    var isToday: Bool {
        Calendar.current.isDateInToday(self)
    }
    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(self)
    }
    var relativeTime: String {
        if isToday {
            return "general_today".localized
        } else if isYesterday {
            return "general_yesterday".localized
        }

        return dateString(self)
    }
}
