//
//  RevokeSicknessStatusReportViewModel.swift
//  CoronaContact
//

import Foundation
import Resolver

class RevokeSicknessStatusReportViewModel: ViewModel {
    @Injected private var healthRepository: HealthRepository
    @Injected private var flowController: RevokeSicknessFlowController
    @Injected private var localStorage: LocalStorage
    @Injected private var configurationService: ConfigurationService

    weak var coordinator: RevokeSicknessStatusReportCoordinator?

    var agreesToTerms = false

    var isValid: Bool {
        agreesToTerms
    }

    var dateLabel: String? {
        return localStorage.attestedSicknessAt?.shortDayShortMonthLongYear ?? ""
    }

    init(with coordinator: RevokeSicknessStatusReportCoordinator) {
        self.coordinator = coordinator
    }

    func goToNext(completion: @escaping () -> Void) {
        guard isValid else {
            return
        }

        guard let attestedSicknessAt = localStorage.attestedSicknessAt else { fatalError() }

        let uploadDays = configurationService.currentConfig.uploadKeyDays
        let startDate = attestedSicknessAt.addDays(-uploadDays)!
        let endDate = attestedSicknessAt
        var diagnosisType: DiagnosisType
        if localStorage.isProbablySick {
            diagnosisType = .yellow
        } else {
            diagnosisType = .green
        }

        flowController.submit(from: startDate, untilIncluding: endDate, diagnosisType: diagnosisType, isRevoken: true) { [weak self] result in
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
                self?.healthRepository.revokeProvenSickness()
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
