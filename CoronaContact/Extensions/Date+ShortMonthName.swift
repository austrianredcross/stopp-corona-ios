//
//  Date+ShortMonthName.swift
//  CoronaContact
//

import Foundation

extension Date {
    private var englishLanguageCode: String {
        return "en"
    }
    
    var sundDownerDate: Date {
        
        var dateComponents = DateComponents()
        dateComponents.year = 2022
        dateComponents.month = 02
        dateComponents.day = 28
        
        return Calendar.current.date(from: dateComponents) ?? Date()
    }
    
    var longDayShortMonthLongYear: String {
        return "\(longDay), \(shortDayShortMonthLongYear)"
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
        return "\(monthAbbrevation), \(dayTime)"
    }
    
    var shortDayShortMonthShortYear: String {
        return Locale.current.languageCode == englishLanguageCode ? "\(monthAbbrevation) \(shortDay), \(shortYear)" : "\(shortDay)\(monthAbbrevation).\(shortYear)"
    }
    
    var dayTime: String {
        return timeOfDay
    }
    
    var shortDayShortMonthLongYear: String {
        return Locale.current.languageCode == englishLanguageCode ? "\(monthAbbrevation) \(shortDay), \(longYear)" : "\(shortDay)\(monthAbbrevation)\(longYear)"
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
    
    private var monthAbbrevation: String {
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
                
        let maxLength = (Locale.current.languageCode == englishLanguageCode ? "01st" : "01.").count

        guard let day = Int(dayFormatter.string(from: self)),
              let dayString = numberFormatter.string(from: NSNumber(value: day)),
              let dayWithPadding = dayString.leftPadding(toLength: maxLength, withPad: "0") else {
            return ""
        }
        
        return dayWithPadding
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
    
    private var shortMonth: String {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "MM"
        
        return dateFormatter.string(from: self)
    }
    
    var shortDayShortMonth: String {
        return Locale.current.languageCode == englishLanguageCode ? "\(shortMonth) \(shortDay)" : "\(shortDay)\(shortMonth)"
    }
}
