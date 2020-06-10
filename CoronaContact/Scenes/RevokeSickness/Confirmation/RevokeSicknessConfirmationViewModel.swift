//
//  RevokeSicknessConfirmationViewModel.swift
//  CoronaContact
//

import Foundation
import Resolver

class RevokeSicknessConfirmationViewModel: ViewModel {
    weak var coordinator: RevokeSicknessConfirmationCoordinator?

    init(with coordinator: RevokeSicknessConfirmationCoordinator) {
        self.coordinator = coordinator
    }

    func returnToMain() {
        coordinator?.finish(animated: true)
    }
}
