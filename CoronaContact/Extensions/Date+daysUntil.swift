//
//  Date+daysUntil.swift
//  CoronaContact
//

import Foundation

extension Date {
    /// Disregards time of day
    func days(until date: Date?) -> Int? {
        guard let date = date else {
            return nil
        }

        let startOfDay = Calendar.current.startOfDay(for: self)
        let startOfOtherDay = Calendar.current.startOfDay(for: date)

        let dateComponents = Calendar.current.dateComponents([.day], from: startOfDay, to: startOfOtherDay)
        return dateComponents.day
    }
}
