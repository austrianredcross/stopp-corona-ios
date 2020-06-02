//
//  TracingKeys.swift
//  CoronaContact
//

import ExposureNotification
import Foundation

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
        regions = ["AT"]
        appPackageName = NetworkConfiguration.appId
        platform = "ios"
        diagnosisStatus = diagnosisType.statusCode
        self.diagnosisType = diagnosisType
        deviceVerificationPayload = nil
        verificationAuthorityName = "RedCross"
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
        key = temporaryExposureKey.keyData.base64EncodedString()
        password = UUID().uuidString
        intervalNumber = temporaryExposureKey.rollingStartNumber
        intervalCount = temporaryExposureKey.rollingPeriod
        transmissionRisk = temporaryExposureKey.transmissionRiskLevel
    }
}
