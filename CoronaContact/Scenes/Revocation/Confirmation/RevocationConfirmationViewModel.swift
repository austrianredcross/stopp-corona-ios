//
//  RevocationConfirmationViewModel.swift
//  CoronaContact
//

import Foundation
import Resolver

class RevocationConfirmationViewModel: ViewModel {
    @Injected private var localStorage: LocalStorage
    weak var coordinator: RevocationConfirmationCoordinator?

    init(with coordinator: RevocationConfirmationCoordinator) {
        self.coordinator = coordinator
    }

    func onViewDidLoad() {
        localStorage.isProbablySickAt = nil
        localStorage.isUnderSelfMonitoring = false
        localStorage.completedVoluntaryQuarantine = true
        NotificationCenter.default.post(name: .DatabaseSicknessUpdated, object: nil)
    }

    func returnToMain() {
        coordinator?.finish(animated: true)
    }
}
