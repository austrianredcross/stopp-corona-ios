//
//  CryptoService.swift
//  CoronaContact
//

import Foundation
import Resolver

enum CryptoError: Error {
    case general, keyError
    case invalidMessageSize, invalidPadding, invalidDate, invalidUUID, invalidTimestamp, invalidMessageType
    case database
}

class CryptoService {
    @Injected var rsa: RSASwiftGenerator
    @Injected var dba: DatabaseService
    @Injected var config: ConfigurationService

    private let kAddressPrefixLength = 8

    private let kRSABlockSize = kRSASwiftGeneratorKeySize / 8 - 42

    private let kZeroPadding = Data(repeating: 0, count:61)

    lazy var generatedName: String = {
        var name = String(Int.random(in: 10000..<20000))
        name.remove(at: name.startIndex)
        return name
    }()

    func createKeysIfNeeded(finished: ((Bool) -> Void)? = nil) {
        if !UserDefaults.standard.notFreshInstalled {
            rsa.deleteSecureKeyPair()
            UserDefaults.standard.notFreshInstalled = true
        }
        if rsa.keyPairExists() {
            finished?(true)
            return
        }
        rsa.createSecureKeyPair { (success, _) in
            finished?(success)
        }
    }

    func getPublicKey() -> Data? {
        rsa.getPublicKeyData()
    }

    func encrypt(_ message: String, with key: Data, completion: @escaping (Bool, Data?, Error?) -> Void) {
        guard let key = rsa.getPublicKeyFromData(key) else { return completion(false, nil, nil) }
        rsa.encryptMessageWith(publicKey: key, message: message) { (success, data, exception) in
            completion(success, data, exception)
        }
    }

    private func encryptMessage(pubKey: Data, timestamp: Date, type: InfectionWarningType, upgradeUUID: String? = nil) -> OutGoingInfectionWarning? {
        guard let contactKey = rsa.getPublicKeyFromData(pubKey) else { return nil }

        let uuid = UUID(uuidString: upgradeUUID ?? "") ?? UUID()

        let warningMsg = makeInfectionWarning(uuid: uuid, timeStamp: timestamp, type: type)

        var message: OutGoingInfectionWarning?

        rsa.encryptPlainTextWith(publicKey: contactKey,
                                 plainText: warningMsg,
                                 plainTextLen: warningMsg.count) { result in
            switch result {
            case .success(let msg):
                message = OutGoingInfectionWarning(messageType: type,
                                                   uuid: uuid.uuidString,
                                                   pubkey: pubKey,
                                                   timestamp: timestamp,
                                                   base64encoded: msg.base64EncodedString())
            case .failure(let error):
                print("ERROR createInfectionWarnings \(error)")
            }
        }
        return message
    }

    func createInfectionWarnings(type: InfectionWarningType) -> Result<[OutGoingInfectionWarningWithAddressPrefix], CryptoError> {
        let warningTime = config.currentConfig.warnBeforeSymptoms

        var contacts: [Contact] = []
        var updateContacts: [ContactUpdate] = []

        if type == .yellow { // yellow messages are only possible if the current state is green
            dba.updateWarningTypeOnAllOutgoingMessages(type: .green)
        }

        if [.red, .green].contains(type) { // for those types we need to update old messages
            updateContacts.append(contentsOf: dba.getContactsToUpdate())
        }

        if [.yellow, .red].contains(type) { // for those types we need to inform new contacts
            if updateContacts.count > 0 {
                // we get all contacts since the last update message
                if let lastTimestamp = updateContacts.last?.created, case .success(let newContacts) = dba.getContacts(afterTimestamp: lastTimestamp) {
                    contacts.append(contentsOf: newContacts)
                }
            } else {
                // we get all contacts of the last configured hours
                if case .success(let newContacts) = dba.getContacts(hours: warningTime) {
                    contacts.append(contentsOf: newContacts)
                }
            }
        }

        var warningMessages: [OutGoingInfectionWarningWithAddressPrefix] = []
        for contact in contacts {
            if let warning = encryptMessage(pubKey: contact.pubKey, timestamp: contact.timestamp, type: type) {
                let addressPrefix = getPublicKeyPrefix(publicKey: contact.pubKey)
                warningMessages.append(OutGoingInfectionWarningWithAddressPrefix(outGoingInfectionWarning: warning,
                                                                                 addressPrefix: addressPrefix))
            }
        }
        for updateContact in updateContacts {
            if let warning = encryptMessage(pubKey: updateContact.pubKey,
                                            timestamp: updateContact.timestamp,
                                            type: type,
                                            upgradeUUID: updateContact.uuid) {
                let addressPrefix = getPublicKeyPrefix(publicKey: updateContact.pubKey)
                warningMessages.append(OutGoingInfectionWarningWithAddressPrefix(outGoingInfectionWarning: warning,
                                                                                 addressPrefix: addressPrefix))
            }
        }
        return .success(warningMessages)
    }

    // To byte array
    private func byteArray<T>(from value: T) -> [UInt8] where T: FixedWidthInteger {
        withUnsafeBytes(of: value.bigEndian, Array.init)
    }

    func makeInfectionWarning(uuid: UUID, timeStamp: Date, type: InfectionWarningType) -> [UInt8] {
        let messageType: Character = type.rawValue

        let messageTypeArray: [UInt8] = [messageType.asciiValue!]
        let timeStampArray = byteArray(from: Int(timeStamp.timeIntervalSince1970))
        let uuidArray = withUnsafePointer(to: uuid.uuid) {
            Data(bytes: $0, count: MemoryLayout.size(ofValue: uuid.uuid))
        }
        return kZeroPadding + messageTypeArray + timeStampArray + uuidArray
    }

    private func parseInfectionWarning(_ data: Data) -> Swift.Result<ParsedInfectionWarning, CryptoError> {
        guard data.count == kRSABlockSize else { return .failure(.invalidMessageSize) }
        guard data[0..<61] == kZeroPadding else { return .failure(.invalidPadding) }
        guard let messageTypeData = String(bytes: data[61..<62],
                                           encoding: .utf8) else { return .failure(.invalidMessageType) }
        let timeStamp = UInt64(bigEndian: data[62..<70].withUnsafeBytes { $0.pointee })
        guard let uuid = data[70..<86].uuid else { return .failure(.invalidUUID) }
        guard let warningType = InfectionWarningType(rawValue: Character(messageTypeData)) else { return .failure(.invalidMessageType) }
        let date = Date(timeIntervalSince1970: TimeInterval(timeStamp))
        return .success(ParsedInfectionWarning(type: warningType, timeStamp: date, uuid: uuid))
    }

    func parseIncomingInfectionWarnings(_ warnings: [IncomingInfectionMessage], completion: @escaping ((Result<Int, CryptoError>) -> Void)) {

        var lastProcessedMessage = 0
        var decryptedWarnings: [Data] = []

        for warning in warnings {
            if let data = Data(base64Encoded: warning.message) {
                rsa.decryptMessageWithPrivateKey(data) { result in
                    switch result {
                    case .success(let message):
                        decryptedWarnings.append(message)
                    case .failure:
                        ()
                    }
                }
            }
            lastProcessedMessage = warning.identifier
        }

        for warning in decryptedWarnings {
            if case .success(let processedWarning) = parseInfectionWarning(warning),
                processedWarning.timeStamp <= Date() {
                dba.saveIncomingInfectionWarning(uuid: processedWarning.uuid.uuidString,
                                                 warningType: processedWarning.type,
                                                 contactTimeStamp: processedWarning.timeStamp)
            }
        }
        completion(.success(lastProcessedMessage))
    }

    public func getMyPublicKeyPrefix() -> String? {
        guard let publicKey = rsa.getPublicKeyData() else {
            return nil
        }

        return getPublicKeyPrefix(publicKey: publicKey)
    }

    public func getPublicKeyPrefix(publicKey: Data) -> String {
        let fingerprint = rsa.sha256(data: publicKey)

        let prefixByteCount = (kAddressPrefixLength - 1) / 8 + 1
        let prefixString = fingerprint
                // get relervant bytes
                .prefix(prefixByteCount)
                // map byte to 8 bits
                .flatMap { currentByte in
                    (0...7).reversed().map { currentBitPos in
                         (currentByte >> (currentBitPos)) & 0b1
                    }
                }
                // get relevant bits
                .prefix(kAddressPrefixLength)
                // map bits to digit string ("1"/"0")
                .map { String($0) }
                // join digits to string
                .joined()

        return prefixString
    }

}
