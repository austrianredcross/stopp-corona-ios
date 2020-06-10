//
//  ExposureKeyManager.swift
//  CoronaContact
//

import CryptoKit
import ExposureNotification
import Foundation
import Resolver

class ExposureKeyManager {
    func getKeysForUpload(keys: [ENTemporaryExposureKey]) throws -> [TemporaryExposureKey] {
        let timestamps = keys.map(\.rollingStartNumber)
        let passwords = try TracingKeyPassword.getPasswordsFor(timestamps: timestamps)
        return keys.map { key in
            TemporaryExposureKey(temporaryExposureKey: key, password: passwords[key.rollingStartNumber])
        }
    }
}
