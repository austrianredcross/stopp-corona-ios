//
//  SelfTestingConfirmationViewModel.swift
//  CoronaContact
//

import Foundation

class SelfTestingConfirmationViewModel: ViewModel {
    weak var coordinator: SelfTestingConfirmationCoordinator?

    init(with coordinator: SelfTestingConfirmationCoordinator) {
        self.coordinator = coordinator
    }

    func onViewDidLoad() {
        UserDefaults.standard.isProbablySick = true
        UserDefaults.standard.isProbablySickAt = Date()
        NotificationCenter.default.post(name: .DatabaseSicknessUpdated, object: nil)
    }

    func showQuarantineGuidelines() {
        coordinator?.showQuarantineGuidelines()
    }

    func returnToMain() {
        coordinator?.finish(animated: true)
    }
}
