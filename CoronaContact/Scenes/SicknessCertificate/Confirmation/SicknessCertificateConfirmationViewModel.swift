//
//  SicknessCertificateConfirmationViewModel.swift
//  CoronaContact
//

import Foundation
import Resolver

class SicknessCertificateConfirmationViewModel: ViewModel {
    @Injected private var localStorage: LocalStorage
    
    weak var coordinator: SicknessCertificateConfirmationCoordinator?
    
    var updateKeys: Bool {
        localStorage.missingUploadedKeysAt != nil
    }

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
