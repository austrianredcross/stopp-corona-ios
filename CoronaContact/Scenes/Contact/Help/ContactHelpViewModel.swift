//
//  ContactHelpViewModel.swift
//  CoronaContact
//

import Foundation

class ContactHelpViewModel: ViewModel {
    weak var coordinator: ContactHelpCoordinator?

    init(with coordinator: ContactHelpCoordinator) {
        self.coordinator = coordinator
    }

    func close() {
        coordinator?.close()
    }

    func openFAQ() {
        coordinator?.openFAQ()
    }
}
