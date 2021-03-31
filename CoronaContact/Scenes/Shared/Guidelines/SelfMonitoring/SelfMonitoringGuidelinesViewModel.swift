//
//  SelfMonitoringGuidelinesViewModel.swift
//  CoronaContact
//

import Foundation
import Resolver

class SelfMonitoringGuidelinesViewModel: ViewModel {
    @Injected private var localStorage: LocalStorage
    weak var coordinator: SelfMonitoringGuidelinesCoordinator?

    init(with coordinator: SelfMonitoringGuidelinesCoordinator) {
        self.coordinator = coordinator
    }

    var dateLabel: String {
        return localStorage.performedSelfTestAt?.shortDateWithTime ?? ""
    }

    func buttonTapped() {
        coordinator?.selfTesting()
    }

    func viewClosed() {
        coordinator?.finish()
    }
}
