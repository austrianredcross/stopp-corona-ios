//
//  WhatsNewViewModel.swift
//  CoronaContact
//

import Foundation
import Resolver

class WhatsNewViewModel {
    @Injected
    private var repository: WhatsNewRepository
    weak var coordinator: WhatsNewCoordinator?

    var whatsNewText: String? {
        repository.allHistoryItems.last
    }

    func okButtonTapped() {
        coordinator?.dismiss()
    }
}
