//
//  Date+ShortMonthName.swift
//  CoronaContact
//

import Foundation

extension Date {
    private var englishLanguageCode: String {
        return "en"
    }
    
    var longDayShortMonthLongYear: String {
        let year = Locale.current.languageCode == englishLanguageCode ? ", \(longYear)" : " \(longYear)"
        
        return "\(longDay), \(shortMonth)\(year)"
    }
    
    var longDayMonthLongYear: String {
        return "\(longDay), \(shortDayShortMonthLongYear)"
    }
    
    var shortDateWithTime: String {
        return "\(shortDayShortMonthLongYear), \(timeOfDay)"
    }
    
    var shortDayLongMonth: String {
        return  Locale.current.languageCode == englishLanguageCode ? "\(longMonth), \(shortDay)" : "\(shortDay) \(longMonth)"
    }
    
    var shortMonthWithTime: String {
        return "\(shortMonth), \(dayTime)"
    }
    
    var shortDayShortMonthShortYear: String {
        return Locale.current.languageCode == englishLanguageCode ? "\(shortMonth) \(shortDay), \(shortYear)" : "\(shortDay)\(shortMonth).\(shortYear)"
    }
    
    var dayTime: String {
        return timeOfDay
    }
    
    var shortDayShortMonthLongYear: String {
        return Locale.current.languageCode == englishLanguageCode ? "\(shortMonth) \(shortDay), \(longYear)" : "\(shortDay)\(shortMonth).\(longYear)"
    }
    
    private var longYear: String {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy"
        
        return dateFormatter.string(from: self)
    }
    
    private var shortYear: String {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yy"
        
        return dateFormatter.string(from: self)
    }
    
    private var shortMonth: String {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "MMM"
        
        return dateFormatter.string(from: self)
    }
    
    private var longMonth: String {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "MMMM"
        
        return dateFormatter.string(from: self)
    }
    
    private var hourOnly: String {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "H"
        
        return dateFormatter.string(from: self)
    }
    
    // Source: https://stackoverflow.com/questions/31546621/display-date-in-st-nd-rd-and-th-format
    private var shortDay: String {
        // When using english locale this will add the st, nd, rd.
        // When using german locale this will add an dot.
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .ordinal
        
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "dd"
                
        guard let dayString = Int(dayFormatter.string(from: self)) else {
            return ""
        }
        let dayNumber = NSNumber(value: dayString)
        
        return numberFormatter.string(from: dayNumber) ?? ""
    }
    
    private var longDay: String {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "EEEE"
        
        return dateFormatter.string(from: self)
    }
    
    private var timeOfDay: String {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "HH:mm"
        
        return dateFormatter.string(from: self)
    }
}
