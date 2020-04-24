//
//  SicknessCertificateConfirmationViewModel.swift
//  CoronaContact
//

import Foundation
import Resolver

class SicknessCertificateConfirmationViewModel: ViewModel {
    weak var coordinator: SicknessCertificateConfirmationCoordinator?
    @Injected var databaseService: DatabaseService

    init(with coordinator: SicknessCertificateConfirmationCoordinator) {
        self.coordinator = coordinator
    }

    func onViewDidLoad() {
        databaseService.saveSicknessState(true)
    }

    func showQuarantineGuidelines() {
        coordinator?.showQuarantineGuidelines()
    }

    func returnToMain() {
        coordinator?.finish(animated: true)
    }
}
