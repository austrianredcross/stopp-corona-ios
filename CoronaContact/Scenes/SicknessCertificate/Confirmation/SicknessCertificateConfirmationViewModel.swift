//
//  SicknessCertificateConfirmationViewModel.swift
//  CoronaContact
//

import Foundation
import Resolver

class SicknessCertificateConfirmationViewModel: ViewModel {
    weak var coordinator: SicknessCertificateConfirmationCoordinator?
    @Injected private var localStorage: LocalStorage

    init(with coordinator: SicknessCertificateConfirmationCoordinator) {
        self.coordinator = coordinator
    }

    func onViewDidLoad() {
        localStorage.attestedSicknessAt = Date()
    }

    func showQuarantineGuidelines() {
        coordinator?.showQuarantineGuidelines()
    }

    func returnToMain() {
        coordinator?.finish(animated: true)
    }
}
