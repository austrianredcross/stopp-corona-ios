//
// DebugViewModel.swift
// CoronaContact
//

import Resolver
import UIKit

// swiftlint:disable:line_length
let simulatedKey = "MIGJAoGBAMvH7iUvrAODD2NwS7ZRRFrr31sJdJHpvhFaR4EZt6lIZvXFzWnqdvRCg3VmpdsJtqzsZEzsFhINXSfNpXAFj2Sb67Yrs4kWhVtEXq" +
    "I0wuYVH0qsCvfnqGTqYiyp+LzD66FkmCnVvnFxoTaQOB3K0B3DPEkgAlmLQdSgYWfIj1Z3AgMBAAE="

// swiftlint:enable:line_length

class DebugViewModel: ViewModel {
    weak var viewController: DebugViewController?
    weak var coordinator: DebugCoordinator?

    @Injected var dba: DatabaseService
    @Injected var crypto: CryptoService
    @Injected var network: NetworkService
    @Injected var notificationService: NotificationService
    var timer: Timer?
    var numberOfContacts = 0

    init(coordintator: DebugCoordinator) {
        coordinator = coordintator
    }

    func close() {
        coordinator?.finish(animated: true)
    }

    func shareLog() {
        coordinator?.shareLog()
    }

    func resetLog() {
        LoggingService.deleteLogFile()
    }

    func addHandShakes() {
        // TODO: remove
    }

    func addRedInfectionMessage() {
        // TODO: remove
    }

    func addYellowInfectionMessage() {
        // TODO: remove
    }

    func scheduleTestNotifications() {
        notificationService.showTestNotifications()
    }

    func attestSickness() {
        dba.saveSicknessState(true)
    }
}
