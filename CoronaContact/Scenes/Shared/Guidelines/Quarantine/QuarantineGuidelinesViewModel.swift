//
//  QuarantineGuidelinesViewModel.swift
//  CoronaContact
//

import Foundation
import Resolver

private let dateFormatter = DateFormatter()

private let dateString: (Date) -> String = { date in
    let format = DateFormatter.dateFormat(fromTemplate: "dd.MMMM", options: 0, locale: Locale.current)
    dateFormatter.dateFormat = format
    return dateFormatter.string(from: date)
}

class QuarantineGuidelinesViewModel: ViewModel {
    weak var coordinator: QuarantineGuidelinesCoordinator?

    init(with coordinator: QuarantineGuidelinesCoordinator) {
        self.coordinator = coordinator
    }
    
    private var quarantineDateString: String? {
        
        let healtRepository: HealthRepository = Resolver.resolve()
            
        guard let monitoringDays = healtRepository.userHealthStatus.quarantineDays, let date = Date().addDays(monitoringDays) else { return nil }
        
        return dateString(date)
    }
    
    var guidelines: [Instruction] {
        [
            .init(index: 1, text: String(format: "quarantine_guidelines_first".localized, quarantineDateString!)),
            .init(index: 2, text: "quarantine_guidelines_second".localized),
            .init(index: 3, text: "quarantine_guidelines_third".localized),
            .init(index: 4, text: "quarantine_guidelines_fourth".localized),
        ]
    }
}
