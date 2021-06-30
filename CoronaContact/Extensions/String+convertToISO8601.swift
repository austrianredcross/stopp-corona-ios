//
//  String+convertToISO8601.swift
//  CoronaContact
//

import Foundation

extension String {
    
    func convertToDate() throws -> Date {        
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate]

        guard let date = dateFormatter.date(from: self) else { throw AGESError.wrongDateFormat }
                
        return date
    }
}
