//
//  ExposureKeyManager.swift
//  CoronaContact
//

import ExposureNotification
import Foundation
import Resolver
import CryptoKit

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

    func getKeysForUpload(keys: [ENTemporaryExposureKey]) -> [TemporaryExposureKey] {
        return keys.map {
            TemporaryExposureKey.init(temporaryExposureKey: $0, salt: exposureKeySalt)
        }
    }

    func persistKeysAfterUpload(keys:[TemporaryExposureKey], database: DatabaseService = Resolver.resolve()) {
        try? TemporaryExposureKey.persistKeys(dbs: database, keys: keys)
    }

}
