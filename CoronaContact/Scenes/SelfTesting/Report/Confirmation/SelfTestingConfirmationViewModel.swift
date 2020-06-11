//
//  SelfTestingConfirmationViewModel.swift
//  CoronaContact
//

import Foundation
import Resolver

class SelfTestingConfirmationViewModel: ViewModel {
    weak var coordinator: SelfTestingConfirmationCoordinator?
    let updateKeys: Bool

    init(with coordinator: SelfTestingConfirmationCoordinator, updateKeys: Bool) {
        self.coordinator = coordinator
        self.updateKeys = updateKeys
    }

    func showQuarantineGuidelines() {
        coordinator?.showQuarantineGuidelines()
    }

    func returnToMain() {
        coordinator?.finish(animated: true)
    }
}
