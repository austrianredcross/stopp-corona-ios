//
//  ENExposureConfiguration+init.swift
//  CoronaContact
//

import ExposureNotification
import Foundation

extension ENExposureConfiguration {
    convenience init(_ configuration: ExposureConfiguration) {
        self.init()

        minimumRiskScore = configuration.minimumRiskScore
        attenuationLevelValues = configuration.attenuationLevelValues as [NSNumber]
        daysSinceLastExposureLevelValues = configuration.daysSinceLastExposureLevelValues as [NSNumber]
        durationLevelValues = configuration.durationLevelValues as [NSNumber]
        transmissionRiskLevelValues = configuration.transmissionRiskLevelValues as [NSNumber]
        metadata = ["attenuationDurationThresholds": configuration.attenuationDurationThresholds]
    }
}
