//
//  QuarantineGuidelinesViewModel.swift
//  CoronaContact
//

import Foundation

class QuarantineGuidelinesViewModel: ViewModel {
    weak var coordinator: QuarantineGuidelinesCoordinator?

    init(with coordinator: QuarantineGuidelinesCoordinator) {
        self.coordinator = coordinator
    }
}
