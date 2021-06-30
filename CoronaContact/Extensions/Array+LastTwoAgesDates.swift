//
//  Array+LastTwoAgesDates.swift
//  CoronaContact
//

import Foundation

typealias LastTwoAGESDates = (lastDay: AGESDate, penultimateDay: AGESDate)
extension Array where Element: AGESDate {
    
    func lastTwoElements() -> LastTwoAGESDates? {
        
        guard self.count > 1 else { return nil }

        let sortedArray = self.sorted(by: { $0.agesDateString < $1.agesDateString })
        
        guard let last = sortedArray.last, let penultimate = sortedArray.dropLast().last else { return nil }
        return LastTwoAGESDates(lastDay: last, penultimateDay: penultimate)
        
    }
}
