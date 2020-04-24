//
//  SelfMonitoringGuidelinesViewModel.swift
//  CoronaContact
//

import Foundation

private let dateFormatter = DateFormatter()

private let dateString: (Date) -> String = { date in
    dateFormatter.dateFormat = "self_monitoring_guidelines_date_format".localized
    return dateFormatter.string(from: date)
}

class SelfMonitoringGuidelinesViewModel: ViewModel {
    weak var coordinator: SelfMonitoringGuidelinesCoordinator?

    init(with coordinator: SelfMonitoringGuidelinesCoordinator) {
        self.coordinator = coordinator
    }

    var dateLabel: String {
        guard let date = UserDefaults.standard.performedSelfTestAt else {
            return ""
        }

        return dateString(date)
    }

    func buttonTapped() {
        coordinator?.selfTesting()
    }

    func viewClosed() {
        coordinator?.finish()
    }
}
