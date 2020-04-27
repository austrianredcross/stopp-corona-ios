//
//  SuspicionGuidelinesViewModel.swift
//  CoronaContact
//

import Foundation

class SuspicionGuidelinesViewModel: ViewModel {
    weak var coordinator: SuspicionGuidelinesCoordinator?

    var endOfQuarantine: String? {
        userHealthStatus?.endOfQuarantine
    }

    var userHealthStatus: UserHealthStatus?

    init(with coordinator: SuspicionGuidelinesCoordinator) {
        self.coordinator = coordinator
    }

    func buttonTapped() {
        coordinator?.reportSick()
    }

    func viewClosed() {
        coordinator?.finish()
    }
}
