//
//  ExposureConfiguration.swift
//  CoronaContact
//

import ExposureNotification
import Foundation

struct ExposureConfiguration: Codable {
    private enum CodingKeys: String, CodingKey {
        case
            minimumRiskScore = "minimum_risk_score",
            dailyRiskThreshold = "daily_risk_threshold",
            attenuationDurationThresholds = "attenuation_duration_thresholds",
            attenuationLevelValues = "attenuation_level_values",
            daysSinceLastExposureLevelValues = "days_since_last_exposure_level_values",
            durationLevelValues = "duration_level_values",
            transmissionRiskLevelValues = "transmission_risk_level_values"
    }

    let minimumRiskScore: ENRiskScore
    let dailyRiskThreshold: ENRiskScore
    let attenuationDurationThresholds: [Int]
    let attenuationLevelValues: [ENRiskLevelValue]
    let daysSinceLastExposureLevelValues: [ENRiskLevelValue]
    let durationLevelValues: [ENRiskLevelValue]
    let transmissionRiskLevelValues: [ENRiskLevelValue]
}
