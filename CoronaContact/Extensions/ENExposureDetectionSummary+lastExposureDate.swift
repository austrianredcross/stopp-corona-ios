//
//  ENExposureDetectionSummary+lastExposureDate.swift
//  CoronaContact
//

import ExposureNotification
import Foundation

extension ENExposureDetectionSummary {
    var lastExposureDate: Date? {
        Calendar.current.date(byAdding: .day, value: -daysSinceLastExposure, to: Date())
    }
}
