//
//  LocalStorage.swift
//  CoronaContact
//

import Foundation

class LocalStorage {

    /// the user manually disabled the background handshake
    @Persisted(userDefaultsKey: "backgroundHandShakeDisabled", notificationName: .init("BackgroundHandshakeDisabled"), defaultValue: false)
    var backgroundHandshakeDisabled: Bool

}
