//
//  SelfTestingConfirmationViewModel.swift
//  CoronaContact
//

import Foundation
import Resolver

class SelfTestingConfirmationViewModel: ViewModel {
    @Injected private var localStorage: LocalStorage
    
    weak var coordinator: SelfTestingConfirmationCoordinator?
    
    var updateKeys: Bool {
        localStorage.missingUploadedKeysAt != nil
    }

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
