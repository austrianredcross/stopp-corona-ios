//
//  AttestedSicknessGuidelinesViewModel.swift
//  CoronaContact
//

import Foundation
import Resolver

private let dateFormatter = DateFormatter()

private let quarantineDateString: (Date) -> String = { date in
    dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "dd.MMMM", options: 0, locale: Locale.current)
    return dateFormatter.string(from: date)
}

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
        
        return quarantineDateString(endOfQuarantine)
    }
    
    var guidelines: [Instruction] {
        [
            .init(index: 1, text: String(format: "sickness_certificate_quarantine_guidelines_steps_first".localized, endOfQuarantine)),
            .init(index: 2, text: "sickness_certificate_quarantine_guidelines_steps_second".localized),
            .init(index: 3, text: "sickness_certificate_quarantine_guidelines_steps_third".localized),
            .init(index: 4, text: "sickness_certificate_quarantine_guidelines_steps_fourth".localized),
        ]
    }
}
