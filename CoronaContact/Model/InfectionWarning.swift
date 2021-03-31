//
//  InfectionWarning.swift
//  CoronaContact
//

import Foundation

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

        return self.longMonth
    }
}
