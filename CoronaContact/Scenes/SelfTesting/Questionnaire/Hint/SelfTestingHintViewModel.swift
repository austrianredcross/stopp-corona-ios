//
//  SelfTestingHintViewModel.swift
//  CoronaContact
//

import Foundation
import Resolver

class SelfTestingHintViewModel: ViewModel {

    @Injected private var notificationService: NotificationService
    @Injected private var localStorage: LocalStorage

    weak var coordinator: SelfTestingHintCoordinator?

    init(with coordinator: SelfTestingHintCoordinator) {
        self.coordinator = coordinator
    }

    func onViewDidLoad() {
        localStorage.performedSelfTestAt = Date()

        if localStorage.isUnderSelfMonitoring {
            localStorage.isUnderSelfMonitoring = false
            notificationService.removeSelfTestReminderNotification()
            NotificationCenter.default.post(name: .DatabaseSicknessUpdated, object: nil)
        }
    }

    func returnToMain() {
        coordinator?.popToRoot()
    }

    func viewClosed() {
        coordinator?.finish()
    }
}
