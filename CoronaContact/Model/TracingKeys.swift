//
//  TracingKeys.swift
//  CoronaContact
//

import Foundation
import ExposureNotification

struct TracingKeys: Codable {

    private enum CodingKeys: String, CodingKey {
        case
        temporaryExposureKeys = "temporaryTracingKeys",
        regions, appPackageName, platform, diagnosisStatus,
        diagnosisType, deviceVerificationPayload,
        verificationAuthorityName, verificationPayload
    }

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
         diagnosisType: DiagnosisType,
         verificationPayload: Verification) {
        self.temporaryExposureKeys = temporaryExposureKeys
        self.regions = ["AT"]
        self.appPackageName = NetworkConfiguration.appId
        self.platform = "ios"
        self.diagnosisStatus = diagnosisType.statusCode
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

    var statusCode: Int {
        switch self {
        case .red:
            return 2
        case .yellow:
            return 1
        case .green:
            return 0
        }
    }
}

struct Verification: Codable {
    /// An uuid which was requested via the `/request-tan` endpoint
    let uuid: String
    let authorization: String
}

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
