//
//  TracingKeys.swift
//  CoronaContact
//

import Foundation
import ExposureNotification

@available(iOS 13.5, *)
struct TracingKeys: Codable {
    let temporaryExposureKeys: [TemporaryExposureKey]
    let regions: [String]
    let appPackageName: String
    let platform: String
    let diagnosisStatus: Int
    let diagnosisType: DiagnosisType
    let deviceVerificationPayload: String?
    let verificationAuthorityName: String
    let verificationPayload: Verification

    init(temporaryExposureKeys: [TemporaryExposureKey],
         diagnosisStatus: Int, diagnosisType: DiagnosisType,
         verificationPayload: Verification) {
        self.temporaryExposureKeys = temporaryExposureKeys
        self.regions = ["AT"]
        self.appPackageName = NetworkConfiguration.appId
        self.platform = "ios"
        self.diagnosisStatus = diagnosisStatus
        self.diagnosisType = diagnosisType
        self.deviceVerificationPayload = nil
        self.verificationAuthorityName = "RedCross"
        self.verificationPayload = verificationPayload
    }
}

enum DiagnosisType: String, Codable {
    case red = "red-warning"
    case yellow = "yellow-warning"
    case green = "green-warning"
}

struct Verification: Codable {
    /// An uuid which was requested via the `/request-tan` endpoint
    let uuid: String
    let authorization: String
}

@available(iOS 13.5, *)
struct TemporaryExposureKey: Codable {
    let key: String
    let password: String
    let intervalNumber: ENIntervalNumber
    let intervalCount: ENIntervalNumber
    let transmissionRisk: ENRiskLevel

    init(temporaryExposureKey: ENTemporaryExposureKey) {
        self.key = temporaryExposureKey.keyData.base64EncodedString()
        self.password = UUID().uuidString
        self.intervalNumber = temporaryExposureKey.rollingStartNumber
        self.intervalCount = temporaryExposureKey.rollingPeriod
        self.transmissionRisk = temporaryExposureKey.transmissionRiskLevel
    }
}
