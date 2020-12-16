//
//  ContactSicknessViewModel.swift
//  CoronaContact
//

import Foundation
import Resolver

class ContactSicknessViewModel: ViewModel {
    weak var coordinator: ContactSicknessCoordinator?

    var title: String? {
        contactHealthStatus?.title
    }

    var headline: String? {
        contactHealthStatus?.headline
    }
    
    var description: String? {
        contactHealthStatus?.description
    }

    var descriptionOfEncounters: String? {
        contactHealthStatus?.descriptionOfEncounters(infectionWarnings)
    }

    var endOfQuarantine: String? {
        contactHealthStatus?.endOfQuarantine
    }

    var guidelines: [Instruction] {
        contactHealthStatus?.guidelines ?? []
    }

    var contactHealthStatus: ContactHealthStatus?

    func viewClosed() {
        coordinator?.finish()
    }

    var infectionWarnings: [InfectionWarning] = []

    init(with coordinator: ContactSicknessCoordinator) {
        self.coordinator = coordinator
    }
}
