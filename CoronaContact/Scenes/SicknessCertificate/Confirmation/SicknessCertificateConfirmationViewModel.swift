//
//  SicknessCertificateConfirmationViewModel.swift
//  CoronaContact
//

import Foundation
import Resolver

class SicknessCertificateConfirmationViewModel: ViewModel {
    weak var coordinator: SicknessCertificateConfirmationCoordinator?

    init(with coordinator: SicknessCertificateConfirmationCoordinator) {
        self.coordinator = coordinator
    }

    func showQuarantineGuidelines() {
        coordinator?.showQuarantineGuidelines()
    }

    func returnToMain() {
        coordinator?.finish(animated: true)
    }
}
