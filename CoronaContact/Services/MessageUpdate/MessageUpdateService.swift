//
//  MessageUpdateService.swift
//  CoronaContact
//

import Foundation
import Resolver

class MessageUpdateService {
    @Injected private var network: NetworkService
    @Injected private var crypto: CryptoService
    private var isUpdating = false

    func update() {
        DispatchQueue.global(qos: .default).async { [weak self] in
            if self?.crypto.getPublicKey() != nil {
                self?.requestUpdate(lastDownloadedMessage: UserDefaults.standard.lastDownloadedMessage)
            }
        }
    }

    private func requestUpdate(lastDownloadedMessage: Int) {
        guard let addressPrefix = crypto.getMyPublicKeyPrefix() else {
            return
        }

        guard !isUpdating else { return }
        isUpdating = true

        if lastDownloadedMessage == 0 {
            network.fetchInfectionMessages(addressPrefix: addressPrefix) { result in
                DispatchQueue.global(qos: .default).async { self.handleResult(result) }
            }
        } else {
            network.fetchInfectionMessages(fromId: String(lastDownloadedMessage), addressPrefix: addressPrefix) { result in
                DispatchQueue.global(qos: .default).async { self.handleResult(result) }
            }
        }
    }

    private func handleResult(_ result: Result<InfectionMessagesResponse, NetworkError>) {
        var needToFetchMoreAfter = 0
        if case .success(let response) = result {
            if response.messages.count > 0 {
                crypto.parseIncomingInfectionWarnings(response.messages) { result in
                    if case .success(let lastMessage) = result {
                        if lastMessage > 0 {
                            UserDefaults.standard.lastDownloadedMessage = lastMessage
                            needToFetchMoreAfter = lastMessage
                        }
                    }
                }
            }
        }
        isUpdating = false
        if needToFetchMoreAfter > 0 {
            requestUpdate(lastDownloadedMessage: needToFetchMoreAfter)
        }
    }
}
