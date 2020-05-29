//
//  RevokeSicknessConfirmationViewModel.swift
//  CoronaContact
//

import Foundation
import Resolver

class RevokeSicknessConfirmationViewModel: ViewModel {
    weak var coordinator: RevokeSicknessConfirmationCoordinator?
    @Injected private var localStorage: LocalStorage

    init(with coordinator: RevokeSicknessConfirmationCoordinator) {
        self.coordinator = coordinator
    }

    func onViewDidLoad() {
        localStorage.attestedSicknessAt = nil
    }

    func returnToMain() {
        coordinator?.finish(animated: true)
    }
}
