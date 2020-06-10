//
//  HealthStateController.swift
//  CoronaContact
//

import Foundation
import Resolver

enum HealthStateStatus {
    case provenSick
    case probablySick
    case isUnderSelfMonitoring
    case healthy
}

class HealthStateController {
    @Injected private var localStorage: LocalStorage

    var currentHealth: HealthStateStatus {
        if localStorage.attestedSicknessAt != nil {
            return .provenSick
        }
        if localStorage.isProbablySickAt != nil {
            return .probablySick
        }
        if localStorage.isUnderSelfMonitoring {
            return .isUnderSelfMonitoring
        }
        return .healthy
    }

    var canUploadMissingKeys: Bool {
        guard let missingKeys = localStorage.missingUploadedKeys else {
            return false
        }
        if missingKeys.startOfDayUTC < Date().startOfDayUTC {
            return true
        }
        return false
    }

    func setProbablySick() {
        localStorage.isProbablySickAt = Date()
        localStorage.missingUploadedKeys = Date()
    }

    func setProvenSick() {
        localStorage.attestedSicknessAt = Date()
        if !localStorage.isProbablySick {
            localStorage.missingUploadedKeys = Date()
        }
    }

    func revokeProbablySick() {
        localStorage.attestedSicknessAt = nil
        localStorage.missingUploadedKeys = nil
    }

    func revokeProvenSickness() {
        localStorage.attestedSicknessAt = nil
        localStorage.missingUploadedKeys = nil
    }
}
