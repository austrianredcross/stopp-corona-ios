//
//  Array+ManagingBatchProcessingDates.swift
//  CoronaContact
//

import Foundation

extension Array where Element == Date {
    
    mutating func managingBatchProcessingDates(insert: Date) {
        append(insert)
        
        let sevenDaysInPast = insert.addDays(-7)!
        removeAll(where: { $0.timeIntervalSince1970 < sevenDaysInPast.timeIntervalSince1970 })
    }
    
}
