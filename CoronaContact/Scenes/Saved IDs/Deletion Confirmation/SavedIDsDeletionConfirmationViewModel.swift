//
//  SavedIDsDeletionConfirmationViewModel.swift
//  CoronaContact
//

import Foundation

class SavedIDsDeletionConfirmationViewModel: ViewModel {
    weak var coordinator: SavedIDsCoordinator?

    init(_ coordinator: SavedIDsCoordinator) {
        self.coordinator = coordinator
    }

    func deletionConfirmationAcknowledged() {
        coordinator?.deletionConfirmationAcknowledged()
    }

    func finish() {
        coordinator?.finish(animated: true)
    }
}
