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
        contactHealthStatus?.descriptionOfEncounters(infectionWarnings)
    }
    var headlineGuidelines: String? {
        contactHealthStatus?.headlineGuidelines
    }
    var endOfQuarantine: String? {
        contactHealthStatus?.endOfQuarantine
    }
    var descriptionGuidelines: String? {
        contactHealthStatus?.descriptionGuidelines
    }
    var guidelines: [Instruction] {
        contactHealthStatus?.guidelines ?? []
    }

    var contactHealthStatus: ContactHealthStatus?

    func viewClosed() {
        self.coordinator?.finish()
    }

    var infectionWarnings: [InfectionWarning] = []

    init(with coordinator: ContactSicknessCoordinator) {
        self.coordinator = coordinator
    }
}
