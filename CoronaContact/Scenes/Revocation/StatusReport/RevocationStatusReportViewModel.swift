//
//  RevocationStatusReportViewModel.swift
//  CoronaContact
//

import Foundation
import Resolver

private let dateFormatter = DateFormatter()

private let dateString: (Date) -> String = { date in
    dateFormatter.dateFormat = "revocation_report_status_date_format".localized
    return dateFormatter.string(from: date)
}

class RevocationStatusReportViewModel: ViewModel {
    @Injected private var flowController: RevocationFlowController
    @Injected private var localStorage: LocalStorage
    @Injected private var healthRepository: HealthRepository

    weak var coordinator: RevocationStatusReportCoordinator?

    var agreesToTerms = false

    var isValid: Bool {
        agreesToTerms
    }

    var dateLabel: String? {
        guard let date = localStorage.isProbablySickAt else {
            return nil
        }

        return dateString(date)
    }

    init(with coordinator: RevocationStatusReportCoordinator) {
        self.coordinator = coordinator
    }

    func goToNext(completion: @escaping () -> Void) {
        guard isValid else {
            return
        }
        guard let isProbablySickAt = localStorage.isProbablySickAt else { fatalError() }

        let startDate = isProbablySickAt.addDays(-3)!
        let endDate = isProbablySickAt

        flowController.submit(from: startDate, untilIncluding: endDate) { [weak self] result in
            completion()

            switch result {
            case let .failure(.submission(error)):
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
                self?.healthRepository.revokeProbablySick()
                self?.localStorage.isUnderSelfMonitoring = false
                self?.localStorage.completedVoluntaryQuarantine = true
                self?.coordinator?.showConfirmation()
            default:
                break
            }
        }
    }

    func reportButtonTapped() {
        coordinator?.showConfirmation()
    }
}
