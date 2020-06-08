//
//  ExposureKeyManager.swift
//  CoronaContact
//

import CryptoKit
import ExposureNotification
import Foundation
import Resolver

class ExposureKeyManager {
    let localStorage: LocalStorage = Resolver.resolve()
    var exposureKeySalt: Data = Data()

    init() {
        var keyHash = localStorage.exposureKeySalt
        if keyHash == nil {
            keyHash = generateRandomBytes()
            localStorage.exposureKeySalt = keyHash
        }
        if let salt = keyHash {
            exposureKeySalt = salt
        }
    }

    private func generateRandomBytes() -> Data? {
        var keyData = Data(count: 32)
        let result = keyData.withUnsafeMutableBytes {
            SecRandomCopyBytes(kSecRandomDefault, 32, $0.baseAddress!)
        }
        if result == errSecSuccess {
            return keyData
        } else {
            print("Problem generating random bytes")
            return nil
        }
    }

    func getKeysForUpload(keys: [ENTemporaryExposureKey]) throws -> [TemporaryExposureKey] {
        let timestamps = keys.map(\.rollingStartNumber)
        let passwords = try TracingKeyPassword.getPasswordsFor(timestamps: timestamps)
        return keys.map { key in
            TemporaryExposureKey(temporaryExposureKey: key, password: passwords[key.rollingStartNumber])
        }
    }
}
