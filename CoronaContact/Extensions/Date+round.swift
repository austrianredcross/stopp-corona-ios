//
//  Date+round.swift
//  CoronaContact
//

import Foundation

extension Date {
    func lastFullHour() -> Date {
        var components = NSCalendar.current.dateComponents([.minute, .second, .nanosecond], from: self)
        components.minute = -(components.minute ?? 0)
        components.second = -(components.second ?? 0)
        components.nanosecond = -(components.nanosecond ?? 0)
        return Calendar.current.date(byAdding: components, to: self)!
    }

    func nextHour() -> Date {
        Calendar.current.date(byAdding: .hour, value: 1, to: self)!
    }
}
