//
//  QuarantineGuidelinesViewModel.swift
//  CoronaContact
//

import Foundation
import Resolver

class QuarantineGuidelinesViewModel: ViewModel {
    weak var coordinator: QuarantineGuidelinesCoordinator?

    init(with coordinator: QuarantineGuidelinesCoordinator) {
        self.coordinator = coordinator
    }
    
    private var quarantineDateString: String? {
        
        let healtRepository: HealthRepository = Resolver.resolve()
            
        guard let monitoringDays = healtRepository.userHealthStatus.quarantineDays, let date = Date().addDays(monitoringDays) else { return nil }
        
        return date.shortDayLongMonth
    }
    
    var guidelines: [Instruction] {
        [
            .init(index: 1, text: String(format: "quarantine_guidelines_first".localized, quarantineDateString!), instructionIcon: InstructionIcons.thermometer),
            .init(index: 2, text: "quarantine_guidelines_second".localized, instructionIcon: InstructionIcons.distance),
            .init(index: 3, text: "quarantine_guidelines_third".localized, instructionIcon: InstructionIcons.mask),
            .init(index: 4, text: "quarantine_guidelines_fourth".localized, instructionIcon: InstructionIcons.doctor),
        ]
    }
}
