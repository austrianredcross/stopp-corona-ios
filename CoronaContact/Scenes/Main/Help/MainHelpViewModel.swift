//
//  MainHelpViewModel.swift
//  CoronaContact
//

import Foundation

class MainHelpViewModel: ViewModel {
    weak var coordinator: MainHelpCoordinator?

    init(with coordinator: MainHelpCoordinator) {
        self.coordinator = coordinator
    }

    func close() {
        coordinator?.close()
    }

    func openFAQ() {
        coordinator?.openFAQ()
    }
}
