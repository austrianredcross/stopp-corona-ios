//
//  RevocationConfirmationViewModel.swift
//  CoronaContact
//

import Foundation
import Resolver

class RevocationConfirmationViewModel: ViewModel {
    weak var coordinator: RevocationConfirmationCoordinator?

    init(with coordinator: RevocationConfirmationCoordinator) {
        self.coordinator = coordinator
    }

    func returnToMain() {
        coordinator?.finish(animated: true)
    }
}
