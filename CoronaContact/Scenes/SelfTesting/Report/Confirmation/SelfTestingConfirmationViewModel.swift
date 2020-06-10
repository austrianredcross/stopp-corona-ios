//
//  SelfTestingConfirmationViewModel.swift
//  CoronaContact
//

import Foundation
import Resolver

class SelfTestingConfirmationViewModel: ViewModel {
    weak var coordinator: SelfTestingConfirmationCoordinator?

    init(with coordinator: SelfTestingConfirmationCoordinator) {
        self.coordinator = coordinator
    }

    func showQuarantineGuidelines() {
        coordinator?.showQuarantineGuidelines()
    }

    func returnToMain() {
        coordinator?.finish(animated: true)
    }
}
