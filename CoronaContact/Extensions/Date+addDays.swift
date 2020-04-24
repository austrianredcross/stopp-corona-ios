//
//  Date+addDays.swift
//  CoronaContact
//

import Foundation

extension Date {
    func addDays(_ days: Int) -> Date? {
        Calendar.current.date(byAdding: .day, value: days, to: self)
    }
}
