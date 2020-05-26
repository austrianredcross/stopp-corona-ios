//
//  SavedIDsViewModel.swift
//  CoronaContact
//

import Foundation

class SavedIDsViewModel: ViewModel {
    weak var coordinator: SavedIDsCoordinator?

    init(_ coordinator: SavedIDsCoordinator) {
        self.coordinator = coordinator
    }

    func finish() {
        coordinator?.finish(animated: true)
    }
}
