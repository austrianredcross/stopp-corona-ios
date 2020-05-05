//
//  RevokeSicknessStatusReportViewModel.swift
//  CoronaContact
//

import Foundation
import Resolver

private let dateFormatter = DateFormatter()

private let dateString: (Date) -> String = { date in
    dateFormatter.dateFormat = "revoke_sickness_report_dateformat".localized
    return dateFormatter.string(from: date)
}

class RevokeSicknessStatusReportViewModel: ViewModel {

    @Injected private var flowController: RevokeSicknessFlowController

    weak var coordinator: RevokeSicknessStatusReportCoordinator?

    var agreesToTerms = false

    var isValid: Bool {
        agreesToTerms
    }

    var dateLabel: String? {
        guard let date = UserDefaults.standard.attestedSicknessAt else {
            return nil
        }

        return dateString(date)
    }

    init(with coordinator: RevokeSicknessStatusReportCoordinator) {
        self.coordinator = coordinator
    }

    func goToNext(completion: @escaping () -> Void) {
        guard isValid else {
            return
        }

        flowController.submit { [weak self] result in
            completion()

            switch result {
            case .failure(let error):
                self?.coordinator?.showErrorAlert(
                        title: error.displayableError.title,
                        error: error.displayableError.description,
                        closeAction: { _ in
                            if error.personalDataInvalid {
                                self?.coordinator?.goBackToPersonalData()
                            } else if error.tanInvalid {
                                self?.coordinator?.goBackToTanConfirmation()
                            }
                        }
                )
            case .success:
                self?.coordinator?.showConfirmation()
            }
        }
    }

    func reportButtonTapped() {
        coordinator?.showConfirmation()
    }
}
