//
//  Double+asFormattedString.swift
//  CoronaContact
//

import Foundation

extension Double {
    
    enum SignPrefix: String {
        case positive = "+"
        case negative = "-"
        case zero = "+/-"
    }
    
    var asFormattedString: String {
        
        let numberFormatter = NumberFormatter()
        
        numberFormatter.minimumFractionDigits = 0
        numberFormatter.maximumFractionDigits = 2
        
        // Make self abs so we don't have to check what sign it has.
        guard let formattedString = numberFormatter.string(from: NSNumber(value: abs(self))) else { return "" }
        return formattedString
    }
    
    var asFormattedStringWithSignPrefix: String {
        return "\(signPrefix.rawValue)\(asFormattedString)"
    }
    
    var signPrefix: SignPrefix {
        if self > 0 {
            return .positive
        } else if self < 0 {
            return .negative
        } else {
            return .zero
        }
    }
}
