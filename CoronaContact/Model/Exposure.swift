//
//  Exposure.swift
//  CoronaContact
//

import ExposureNotification
import Foundation

struct Exposure: Codable {
    let date: Date
    let duration: TimeInterval
    let totalRiskScore: ENRiskScore
    let attenuationValue: ENAttenuation
    let transmissionRiskLevel: ENRiskLevel
}
