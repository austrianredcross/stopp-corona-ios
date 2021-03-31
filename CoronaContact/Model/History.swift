//
//  History.swift
//  CoronaContact
//

import Foundation

struct History {
    let date: Date
    let autoDiscovered: Bool
    var dateString: String { date.shortYear }

    var timeRangeString: String {
        let start = date.lastFullHour()
        let end = start.nextHour()
        return "\(start.dayTime) - \(end.dayTime)"
    }
}
