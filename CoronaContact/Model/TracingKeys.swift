//
//  TracingKeys.swift
//  CoronaContact
//

import CryptoKit
import ExposureNotification
import Foundation
import SQLite

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

extension DiagnosisType: Value {

    public static var declaredDatatype = Int.declaredDatatype

    public static func fromDatatypeValue(_ datatypeValue: Int) -> DiagnosisType {
        switch datatypeValue {
        case 2:
            return DiagnosisType.red
        case 1:
            return DiagnosisType.yellow
        default:
            return DiagnosisType.green
        }
    }

    public var datatypeValue: Int {
        self.statusCode
    }
}

struct Verification: Codable {
    /// An uuid which was requested via the `/request-tan` endpoint
    let uuid: String
    let authorization: String
}

struct TemporaryExposureKey: Codable {
    static let table = Table("exposureKeys")
    static let key = Expression<String>("key")
    static let password = Expression<String>("password")
    static let diagnosisType = Expression<DiagnosisType>("diagnosis")
    static let intervalNumber = Expression<ENIntervalNumber>("interval")
    static let intervalCount = Expression<ENIntervalNumber>("count")
    static let transmissionRisk = Expression<ENRiskLevel>("risk")

    let key: String
    let password: String
    let intervalNumber: ENIntervalNumber
    let intervalCount: ENIntervalNumber
    let transmissionRisk: ENRiskLevel

    init(temporaryExposureKey: ENTemporaryExposureKey, salt: Data) {
        key = temporaryExposureKey.keyData.base64EncodedString()
        var passwordData = salt
        passwordData.append(temporaryExposureKey.keyData)
        password = SHA256.hash(data: passwordData).compactMap {
            String(format: "%02x", $0)
        }.joined()
        intervalNumber = temporaryExposureKey.rollingStartNumber
        intervalCount = temporaryExposureKey.rollingPeriod
        transmissionRisk = temporaryExposureKey.transmissionRiskLevel
    }

    static func persistKeys(dbs: DatabaseService, keys: [TemporaryExposureKey]) throws {
        do {
            try keys.forEach { key in
                let insert = TemporaryExposureKey.table.insert(
                        TemporaryExposureKey.key <- key.key,
                        TemporaryExposureKey.password <- key.password,
                        TemporaryExposureKey.intervalNumber <- key.intervalNumber,
                        TemporaryExposureKey.intervalCount <- key.intervalCount,
                        TemporaryExposureKey.transmissionRisk <- key.transmissionRisk
                )
                try dbs.dba.run(insert)
            }
        } catch {
            dbs.log.error(error)
            throw error
        }
    }
}
