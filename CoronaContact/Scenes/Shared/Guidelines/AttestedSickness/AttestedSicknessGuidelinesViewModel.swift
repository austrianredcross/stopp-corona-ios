//
//  AttestedSicknessGuidelinesViewModel.swift
//  CoronaContact
//

import Foundation
import Resolver

private let dateFormatter = DateFormatter()

private let dateString: (Date) -> String = { date in
    dateFormatter.dateFormat = "sickness_certificate_quarantine_guidelines_date_format".localized
    return dateFormatter.string(from: date)
}

class AttestedSicknessGuidelinesViewModel: ViewModel {
    weak var coordinator: AttestedSicknessGuidelinesCoordinator?
    @Injected private var localStorage: LocalStorage

    var attestedSicknessAt: String {
        guard let date = localStorage.attestedSicknessAt else {
            return ""
        }

        return dateString(date)
    }

    init(with coordinator: AttestedSicknessGuidelinesCoordinator) {
        self.coordinator = coordinator
    }
}
