//
//  SelfTestingSelfMonitoringViewModel.swift
//  CoronaContact
//

import Foundation
import Resolver

class SelfTestingSelfMonitoringViewModel: ViewModel {
    @Injected private var notificationService: NotificationService
    @Injected private var localStorage: LocalStorage

    weak var coordinator: SelfTestingSelfMonitoringCoordinator?

    init(with coordinator: SelfTestingSelfMonitoringCoordinator) {
        self.coordinator = coordinator
    }

    func onViewDidLoad() {
        localStorage.isUnderSelfMonitoring = true
        localStorage.performedSelfTestAt = Date()

        NotificationCenter.default.post(name: .DatabaseSicknessUpdated, object: nil)
        notificationService.addSelfTestReminderNotificationIn()
    }

    func returnToMain() {
        coordinator?.popToRoot()
    }

    func viewClosed() {
        coordinator?.finish()
    }
}
