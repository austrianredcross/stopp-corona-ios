//
//  ENIntervalNumber+date.swift
//  CoronaContact
//

import ExposureNotification
import Foundation

extension ENIntervalNumber {
    var date: Date {
        Date(timeIntervalSince1970: Double(self) * 60 * 10)
    }
}
