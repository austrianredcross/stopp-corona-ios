//
//  Date+toIntervalNumber.swift
//  CoronaContact
//

import Foundation

extension Date {
    
    var intervalNumber: Int {
        Int(self.startOfDayUTC().timeIntervalSince1970 / (60 * 10))
    }
}
