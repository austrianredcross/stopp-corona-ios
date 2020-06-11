//
//  ENIntervalNumber+date.swift
//  CoronaContact
//

import ExposureNotification
import Foundation

extension ENIntervalNumber {
    var timeInterval: TimeInterval {
        Double(self) * 60 * 10
    }

    var date: Date {
        Date(timeIntervalSince1970: timeInterval)
    }
}
