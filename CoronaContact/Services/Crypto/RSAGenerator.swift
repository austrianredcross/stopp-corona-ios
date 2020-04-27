//
//  RSAGenerator.swift
//  CoronaContact
//

// NOTICE:
// This file is based on the MIT licensed project: https://github.com/4taras4/RSASwiftGenerator

import Foundation
import Security
import CommonCrypto

// Constants
public var kRSASwiftGeneratorApplicationTag = Bundle.main.bundleIdentifier!.data(using: String.Encoding.utf8)!
public var kRSASwiftGeneratorKeyType = kSecAttrKeyTypeRSA
public var kRSASwiftGeneratorKeySize = 1024
public var kRSASwiftGeneratorCypheredBufferSize = 1024
public var kRSASwiftGeneratorSecPadding: SecPadding = .PKCS1

// swiftlint:disable identifier_name
public enum CryptoException: Error {
    case unknownError
    case duplicateFoundWhileTryingToCreateKey
    case keyNotFound
    case authFailed
    case unableToAddPublicKeyToKeyChain
    case wrongInputDataFormat
    case unableToEncrypt
    case unableToDecrypt
    case unableToSignData
    case unableToVerifySignedData
    case unableToPerformHashOfData
    case unableToGenerateAccessControlWithGivenSecurity
    case outOfMemory
}

// swiftlint:enable identifier_name

public class RSASwiftGenerator: NSObject {
    var publicKey: Data?

    // MARK: - Manage keys
    public func createSecureKeyPair(_ completion: ((_ success: Bool, _ error: CryptoException?) -> Void)? = nil) {
        // private key parameters
        let privateKeyParams: [String: AnyObject] = [
            kSecAttrIsPermanent as String: true as AnyObject,
            kSecAttrApplicationTag as String: kRSASwiftGeneratorApplicationTag as AnyObject
        ]

        // public key parameters
        let publicKeyParams: [String: AnyObject] = [
            kSecAttrIsPermanent as String: true as AnyObject,
            kSecAttrApplicationTag as String: kRSASwiftGeneratorApplicationTag as AnyObject
        ]

        // global parameters for our key generation
        let parameters: [String: AnyObject] = [
            kSecAttrKeyType as String: kRSASwiftGeneratorKeyType,
            kSecAttrKeySizeInBits as String: kRSASwiftGeneratorKeySize as AnyObject,
            kSecPublicKeyAttrs as String: publicKeyParams as AnyObject,
            kSecPrivateKeyAttrs as String: privateKeyParams as AnyObject
        ]

        // asynchronously generate the key pair and call the completion block
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async { () -> Void in
            var pubKey, privKey: SecKey?
            let status = SecKeyGeneratePair(parameters as CFDictionary, &pubKey, &privKey)

            if status == errSecSuccess {
                DispatchQueue.main.async(execute: { completion?(true, nil) })
            } else {
                var error = CryptoException.unknownError
                switch status {
                case errSecDuplicateItem: error = .duplicateFoundWhileTryingToCreateKey
                case errSecItemNotFound: error = .keyNotFound
                case errSecAuthFailed: error = .authFailed
                default: break
                }
                DispatchQueue.main.async(execute: { completion?(false, error) })
            }
        }
    }

    public func getPublicKeyData() -> Data? {
        if let key = publicKey { return key }
        let parameters = [
            kSecClass as String: kSecClassKey,
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrApplicationTag as String: kRSASwiftGeneratorApplicationTag,
            kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
            kSecReturnData as String: true
        ] as [String: Any]
        var data: AnyObject?
        let status = SecItemCopyMatching(parameters as CFDictionary, &data)
        if status == errSecSuccess {
            publicKey = data as? Data
            return publicKey
        } else {
            return nil
        }
    }

    public func getPublicKeyReference() -> SecKey? {
        let parameters = [
            kSecClass as String: kSecClassKey,
            kSecAttrKeyType as String: kSecAttrKeyTypeRSA,
            kSecAttrApplicationTag as String: kRSASwiftGeneratorApplicationTag,
            kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
            kSecReturnRef as String: true
        ] as [String: Any]
        var ref: AnyObject?
        let status = SecItemCopyMatching(parameters as CFDictionary, &ref)
        // swiftlint:disable force_cast
        if status == errSecSuccess { return ref as! SecKey? } else { return nil }
        // swiftlint:enable force_casr
    }

    public func getPrivateKeyReference() -> SecKey? {
        let parameters = [
            kSecClass as String: kSecClassKey,
            kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
            kSecAttrApplicationTag as String: kRSASwiftGeneratorApplicationTag,
            kSecReturnRef as String: true
        ] as [String: Any]
        var ref: AnyObject?
        let status = SecItemCopyMatching(parameters as CFDictionary, &ref)
        // swiftlint:disable force_cast
        if status == errSecSuccess { return ref as! SecKey? } else { return nil }
        // swiftlint:enable force_cast
    }

    public func keyPairExists() -> Bool {
        self.getPublicKeyData() != nil
    }

    @discardableResult
    public func deleteSecureKeyPair() -> Bool {
        // private query dictionary
        let deleteQuery = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: kRSASwiftGeneratorApplicationTag
        ] as [String: Any]
        let status = SecItemDelete(deleteQuery as CFDictionary) // delete private key
        return status == errSecSuccess
    }

    public func getPublicKeyFromData(_ keyData: Data) -> SecKey? {
        let sizeInBits = keyData.count * 8
        let keyDict: [CFString: Any] = [
            kSecAttrKeyType: kSecAttrKeyTypeRSA,
            kSecAttrKeyClass: kSecAttrKeyClassPublic,
            kSecAttrKeySizeInBits: NSNumber(value: sizeInBits),
            kSecReturnPersistentRef: true
        ]

        var error: Unmanaged<CFError>?
        guard let key = SecKeyCreateWithData(keyData as CFData, keyDict as CFDictionary, &error) else {
            return nil
        }
        return key
    }

	// MARK: - Hash algorithms

	/**
	 * Example SHA 256 Hash using CommonCrypto
	 * CC_SHA256 API exposed from from CommonCrypto-60118.50.1:
	 * https://opensource.apple.com/source/CommonCrypto/CommonCrypto-60118.50.1/include/CommonDigest.h.auto.html
	 **/
	func sha256(data: Data) -> Data {
			/// #define CC_SHA256_DIGEST_LENGTH     32
			/// Creates an array of unsigned 8 bit integers that contains 32 zeros
			var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))

		    /// CC_SHA256 performs digest calculation and places the result in the caller-supplied buffer for digest (md)
			/// Takes the strData referenced value (const unsigned char *d) and hashes it into a reference to the digest parameter.
			data.withUnsafeBytes {
				// CommonCrypto
				// extern unsigned char *CC_SHA256(const void *data, CC_LONG len, unsigned char *md)  -|
				// OpenSSL                                                                             |
				// unsigned char *SHA256(const unsigned char *d, size_t n, unsigned char *md)        <-|
				CC_SHA256($0.baseAddress, UInt32(data.count), &digest)
			}

		return Data(digest)
	}

    // MARK: - Cypher and decypher methods

    public func encryptMessageWith(publicKey key: SecKey, message: String,
                                   completion: @escaping (_ success: Bool, _ data: Data?, _ error: CryptoException?) -> Void) {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async { () -> Void in
            guard let messageData = message.data(using: String.Encoding.utf8) else {
                completion(false, nil, .wrongInputDataFormat)
                return
            }
            let plainText = (messageData as NSData).bytes.bindMemory(to: UInt8.self, capacity: messageData.count)
            let plainTextLen = messageData.count
            var cipherData = Data(count: SecKeyGetBlockSize(key))
            let cipherText = cipherData.withUnsafeMutableBytes({ (bytes: UnsafeMutablePointer<UInt8>) -> UnsafeMutablePointer<UInt8> in bytes })
            var cipherTextLen = cipherData.count
            let status = SecKeyEncrypt(key, kRSASwiftGeneratorSecPadding, plainText, plainTextLen, cipherText, &cipherTextLen)
            // analyze results and call the completion in main thread
            DispatchQueue.main.async(execute: { () -> Void in
                completion(status == errSecSuccess, cipherData, status == errSecSuccess ? nil : .unableToEncrypt)
                cipherText.deinitialize(count: cipherTextLen)
            })
            return
        }
    }

    public func encryptPlainTextWith(publicKey key: SecKey,
                                     plainText: UnsafePointer<UInt8>,
                                     plainTextLen: Int,
                                     completion: @escaping (Result<Data, CryptoException>) -> Void) {
        var cipherData = Data(count: SecKeyGetBlockSize(key))
        let cipherText = cipherData.withUnsafeMutableBytes({ (bytes: UnsafeMutablePointer<UInt8>) -> UnsafeMutablePointer<UInt8> in bytes })
        var cipherTextLen = cipherData.count
        let status = SecKeyEncrypt(key, kRSASwiftGeneratorSecPadding, plainText, plainTextLen, cipherText, &cipherTextLen)
        // analyze results and call the completion in main thread
        if status == errSecSuccess {
            completion(.success(cipherData))
        } else {
            completion(.failure(.unableToEncrypt))
        }
        cipherText.deinitialize(count: cipherTextLen)
    }

    public func decryptMessageWithPrivateKeySync(_ encryptedData: Data, completion: @escaping (Result<Data, CryptoException>) -> Void) {
        guard let privateKeyRef = self.getPrivateKeyReference() else { completion(.failure(.keyNotFound)); return }

        let encryptedText = (encryptedData as NSData).bytes.bindMemory(to: UInt8.self, capacity: encryptedData.count)
        let encryptedTextLen = encryptedData.count
        var plainData = Data(count: kRSASwiftGeneratorCypheredBufferSize)
        let plainText = plainData.withUnsafeMutableBytes({ (bytes: UnsafeMutablePointer<UInt8>) -> UnsafeMutablePointer<UInt8> in bytes })
        var plainTextLen = plainData.count

        let status = SecKeyDecrypt(privateKeyRef, kRSASwiftGeneratorSecPadding, encryptedText, encryptedTextLen, plainText, &plainTextLen)

        if status == errSecSuccess {
            plainData.count = plainTextLen
            // Generate and return result string
            completion(.success(plainData as Data))
        } else {
            completion(.failure(.unableToDecrypt))
        }
        plainText.deinitialize(count: plainTextLen)
    }

    public func decryptMessageWithPrivateKey(_ encryptedData: Data, completion: ((Result<Data, CryptoException>) -> Void)) {
        guard let privateKeyRef = self.getPrivateKeyReference() else { return completion(.failure(.keyNotFound)) }

        let encryptedText = (encryptedData as NSData).bytes.bindMemory(to: UInt8.self, capacity: encryptedData.count)
        let encryptedTextLen = encryptedData.count
        var plainData = Data(count: kRSASwiftGeneratorCypheredBufferSize)
        let plainText = plainData.withUnsafeMutableBytes({ (bytes: UnsafeMutablePointer<UInt8>) -> UnsafeMutablePointer<UInt8> in bytes })
        var plainTextLen = plainData.count

        let status = SecKeyDecrypt(privateKeyRef, kRSASwiftGeneratorSecPadding, encryptedText, encryptedTextLen, plainText, &plainTextLen)
        if status == errSecSuccess {
            plainData.count = plainTextLen
            completion(.success(plainData))
        } else {
            completion(.failure(.unableToDecrypt))
        }
        plainText.deinitialize(count: plainTextLen)
    }
}
