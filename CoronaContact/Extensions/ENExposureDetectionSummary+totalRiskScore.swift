//
//  ENExposureDetectionSummary+totalRiskScore.swift
//  CoronaContact
//

import ExposureNotification
import Foundation
import Resolver

extension ENExposureDetectionSummary {
    var totalRiskScore: UInt {
        let configurationService: ConfigurationService = Resolver.resolve()
        let attenuationLevelValues = Set(configurationService.currentConfig.exposureConfiguration.attenuationLevelValues)

        guard let attenuationLevels = attenuationLevelValues.makeUniqueAttenuationValues() else {
            let message = "The `exposure_configuration` object in the configuration.json is misconfigured"
            assertionFailure(message)
            LoggingService.error(message, context: .exposure)
            return UInt.min
        }

        // 5 minutes in seconds
        let detectionInterval: UInt = 5 * 60
        let maxRiskScore = UInt(truncating: attenuationDurations[0]) / detectionInterval * UInt(attenuationLevels.max)
        let medRiskScore = UInt(truncating: attenuationDurations[1]) / detectionInterval * UInt(attenuationLevels.median)
        let minRiskScore = UInt(truncating: attenuationDurations[2]) / detectionInterval * UInt(attenuationLevels.min)

        return maxRiskScore + medRiskScore + minRiskScore
    }
}

private struct UniqueAttenuationLevelValues {
    let max: ENRiskLevelValue
    let min: ENRiskLevelValue
    let median: ENRiskLevelValue
}

private extension Set where Element == ENRiskLevelValue {
    func makeUniqueAttenuationValues() -> UniqueAttenuationLevelValues? {
        var copy = self

        copy.remove(0)

        guard let maxValue = copy.max(), let minValue = copy.min() else {
            return nil
        }

        copy.remove(maxValue)
        copy.remove(minValue)

        guard let medianValue = copy.first else {
            return nil
        }

        return UniqueAttenuationLevelValues(max: maxValue, min: minValue, median: medianValue)
    }
}
