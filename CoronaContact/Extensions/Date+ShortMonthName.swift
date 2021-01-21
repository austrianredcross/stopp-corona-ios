//
//  Date+ShortMonthName.swift
//  CoronaContact
//

import Foundation

extension Date {
    
    var shortMonthNameString: String {
        
        let dateFormatter = DateFormatter()
        
        // MMM gives the short name of the month.
        // In German there is a point after the month in English not, therefore is a space in the English version
        dateFormatter.dateFormat = Locale.current.languageCode == "en" ? "EEEE, dd.MMM yyyy" : "EEEE, dd.MMMyyyy"
        return dateFormatter.string(from: self)
    }
}
