//
//  AGESError.swift
//  CoronaContact
//

import Foundation

enum AGESError: Error {
    case invalidValidation
    case wrongDateFormat
    var title: String {
        return "ages_api_error"
    }
    
    var description: String {
        
        switch self {
        case .invalidValidation:
            return "ages_api_validation_error"
        case .wrongDateFormat:
            return "ages_wrong_date_format_error"
        }
    }
}
