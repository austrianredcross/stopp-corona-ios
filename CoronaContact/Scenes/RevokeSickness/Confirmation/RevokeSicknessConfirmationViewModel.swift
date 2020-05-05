//
//  RevokeSicknessConfirmationViewModel.swift
//  CoronaContact
//

import Foundation

class RevokeSicknessConfirmationViewModel: ViewModel {
    weak var coordinator: RevokeSicknessConfirmationCoordinator?

    init(with coordinator: RevokeSicknessConfirmationCoordinator) {
        self.coordinator = coordinator
    }

    func onViewDidLoad() {
        UserDefaults.standard.attestedSicknessAt = nil
        UserDefaults.standard.hasAttestedSickness = false
        NotificationCenter.default.post(name: .DatabaseSicknessUpdated, object: nil)
    }

    func returnToMain() {
        coordinator?.finish(animated: true)
    }
}
