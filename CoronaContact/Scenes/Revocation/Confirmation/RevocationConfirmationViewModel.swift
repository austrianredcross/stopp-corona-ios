//
//  RevocationConfirmationViewModel.swift
//  CoronaContact
//

import Foundation

class RevocationConfirmationViewModel: ViewModel {
    weak var coordinator: RevocationConfirmationCoordinator?

    init(with coordinator: RevocationConfirmationCoordinator) {
        self.coordinator = coordinator
    }

    func onViewDidLoad() {
        UserDefaults.standard.isProbablySick = false
        UserDefaults.standard.isProbablySickAt = nil
        UserDefaults.standard.isUnderSelfMonitoring = false
        UserDefaults.standard.completedVoluntaryQuarantine = true
        NotificationCenter.default.post(name: .DatabaseSicknessUpdated, object: nil)
    }

    func returnToMain() {
        coordinator?.finish(animated: true)
    }
}
