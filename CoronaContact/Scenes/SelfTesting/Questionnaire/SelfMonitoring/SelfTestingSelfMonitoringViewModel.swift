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
        localStorage.performedSelfTestAt = Date()
        localStorage.isUnderSelfMonitoring = true

        notificationService.addSelfTestReminderNotificationIn()
    }

    func returnToMain() {
        coordinator?.popToRoot()
    }

    func viewClosed() {
        coordinator?.finish()
    }
}
