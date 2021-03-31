//
//  Date+ShortMonthName.swift
//  CoronaContact
//

import Foundation

extension Date {
    var englishLanguageCode: String {
      return "en"
    }
    
    var longDay: String {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "EEEE"
        
        return dateFormatter.string(from: self)
    }
    
    var longYear: String {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy"
        
        return dateFormatter.string(from: self)
    }
    
    var longDayShortMonthLongYear: String {
        let year = Locale.current.languageCode == englishLanguageCode ? ", \(longYear)" : "\(longYear)"

        return "\(longDay), \(shortMonth)\(year)"
    }
    
    var longMonth: String {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = Locale.current.languageCode == englishLanguageCode ? "MMMM dd" : "dd.MMMM"
        
        return dateFormatter.string(from: self)
    }

    var shortDate: String {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = Locale.current.languageCode == englishLanguageCode ? "MM dd, yyyy" : "dd.MM.yyyy"
        
        return dateFormatter.string(from: self)
    }
    
    var shortDateWithTime: String {
        return "\(shortDate), \(dayTime)"
    }
    
    var dayTime: String {
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "HH:mm"

        return dateFormatter.string(from: self)
    }
    
    var shortYear: String {
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = Locale.current.languageCode == englishLanguageCode ? "MM dd, yy" : "dd.MM.yy"

        return dateFormatter.string(from: self)
    }
    
    var shortMonth: String {
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = Locale.current.languageCode == englishLanguageCode ? "MMM dd" : "dd.MMM"
        
        return dateFormatter.string(from: self)
    }
    
    var shortMonthWithTime: String {
        return "\(shortMonth), \(dayTime)"
    }
    
    var hourOnly: String {
        let dateFormatter = DateFormatter()

        dateFormatter.dateFormat = "H"
        
        return dateFormatter.string(from: self)
    }
}
