//
//  JSONEncoder+date.swift
//  CoronaContact
//

import Foundation

struct DateFormatters {
    private var dateFormatters = [Date.DateFormat: DateFormatter]()
    private var configureFormatter: (inout DateFormatter, Date.DateFormat) -> Void

    init(configureFormatter: @escaping (inout DateFormatter, Date.DateFormat) -> Void) {
        self.configureFormatter = configureFormatter
    }

    subscript(format: Date.DateFormat) -> DateFormatter {
        mutating get {
            if let formatter = dateFormatters[format] {
                return formatter
            }

            var formatter = DateFormatter()
            if let utcTimeZone = TimeZone(abbreviation: "UTC") {
                formatter.timeZone = utcTimeZone
            }

            configureFormatter(&formatter, format)
            dateFormatters[format] = formatter

            return formatter
        }
    }
}

var dateFormatters = DateFormatters { (formatter, format) in
    formatter.dateStyle = .short
    formatter.dateFormat = format.rawValue
}

extension JSONEncoder.DateEncodingStrategy {
    static var api: JSONEncoder.DateEncodingStrategy = .formatted(dateFormatters[.api])
}

extension JSONEncoder {

    static let withApiDateFormat: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .api
        return encoder
    }()

    static let withUnixTimestampDateFormat: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        return encoder
    }()
}

public extension Date {
    enum DateFormat: String, Hashable, CaseIterable {
        case api = "dd.MM.yyyy"
        case iso = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    }
}
