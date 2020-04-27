//
//  History.swift
//  CoronaContact
//

import Foundation

private let dateFormatter = DateFormatter()

private let timeStringFormatter: (Date) -> String = { date in
    dateFormatter.dateFormat = "history_time_format".localized
    return dateFormatter.string(from: date)
}

private let dateStringFormatter: (Date) -> String = { date in
    dateFormatter.dateFormat = "history_date_format".localized
    return dateFormatter.string(from: date)
}

struct History {
    let date: Date
    let autoDiscovered: Bool
    var dateString: String { dateStringFormatter(date) }

    var timeRangeString: String {
        let start = date.lastFullHour()
        let end = start.nextHour()
        return "\(timeStringFormatter(start)) - \(timeStringFormatter(end))"
    }
}
