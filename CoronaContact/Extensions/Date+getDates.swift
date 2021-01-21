//
//  Date+getDates.swift
//  CoronaContact
//

import Foundation

extension Date {
    
    func getDates(forLastDays nDays: Int) -> [Date] {
        
        let cal = Calendar.current
        var date = self.startOfDayUTC()
        var arrDates = [date]
        
        for _ in 1 ... nDays {
            date = cal.date(byAdding: .day, value: -1, to: date)!
            arrDates.append(date)
        }
        
        return arrDates
    }
}
