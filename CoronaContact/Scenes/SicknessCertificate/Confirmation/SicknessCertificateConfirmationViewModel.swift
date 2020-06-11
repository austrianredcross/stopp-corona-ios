//
//  SicknessCertificateConfirmationViewModel.swift
//  CoronaContact
//

import Foundation
import Resolver

class SicknessCertificateConfirmationViewModel: ViewModel {
    weak var coordinator: SicknessCertificateConfirmationCoordinator?
    let updateKeys: Bool

    init(with coordinator: SicknessCertificateConfirmationCoordinator, updateKeys: Bool) {
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
