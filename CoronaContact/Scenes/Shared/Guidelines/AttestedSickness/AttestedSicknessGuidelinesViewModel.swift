//
//  AttestedSicknessGuidelinesViewModel.swift
//  CoronaContact
//

import Foundation
import Resolver

class AttestedSicknessGuidelinesViewModel: ViewModel {
    weak var coordinator: AttestedSicknessGuidelinesCoordinator?
    let healthRepository: HealthRepository = Resolver.resolve()

    init(with coordinator: AttestedSicknessGuidelinesCoordinator) {
        self.coordinator = coordinator
    }
        
    var endOfQuarantine: String {
        guard let quarantineDays = healthRepository.userHealthStatus.quarantineDays, let endOfQuarantine = Date().addDays(quarantineDays) else {
            return ""
        }
        
        return endOfQuarantine.shortDayLongMonth
    }
    
    var guidelines: [Instruction] {
        [
            .init(index: 1, text: String(format: "sickness_certificate_quarantine_guidelines_steps_first".localized, endOfQuarantine), instructionIcon: InstructionIcons.house),
            .init(index: 2, text: "sickness_certificate_quarantine_guidelines_steps_second".localized, instructionIcon: InstructionIcons.pcr),
            .init(index: 3, text: "sickness_certificate_quarantine_guidelines_steps_third".localized, instructionIcon: InstructionIcons.thermometer),
            .init(index: 4, text: "sickness_certificate_quarantine_guidelines_steps_fourth".localized, instructionIcon: InstructionIcons.neighbor),
            .init(index: 5, text: "sickness_certificate_quarantine_guidelines_steps_fifth".localized, instructionIcon: InstructionIcons.questionmark),
        ]
    }
}
