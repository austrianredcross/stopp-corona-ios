//
//  SelfTestingSelfMonitoringViewModel.swift
//  CoronaContact
//

import Foundation
import Resolver

class SelfTestingSelfMonitoringViewModel: ViewModel {

    @Injected private var notificationService: NotificationService

    weak var coordinator: SelfTestingSelfMonitoringCoordinator?

    init(with coordinator: SelfTestingSelfMonitoringCoordinator) {
        self.coordinator = coordinator
    }

    func onViewDidLoad() {
        UserDefaults.standard.isUnderSelfMonitoring = true
        UserDefaults.standard.performedSelfTestAt = Date()

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
