//
//  StartMenuSimpleWebViewViewModel.swift
//  CoronaContact
//

import Foundation

class StartMenuSimpleWebViewViewModel: ViewModel {

    weak var coordinator: StartMenuSimpleWebViewCoordinator?

    var website: Website = .imprint

    init(with coordinator: StartMenuSimpleWebViewCoordinator) {
        self.coordinator = coordinator
    }

    func viewClosed() {
        coordinator?.finish()
    }
}
