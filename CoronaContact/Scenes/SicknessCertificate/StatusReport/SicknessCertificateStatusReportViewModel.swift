//
//  SicknessCertificateStatusReportViewModel.swift
//  CoronaContact
//

import Foundation
import Resolver

class SicknessCertificateStatusReportViewModel: ViewModel {
    @Injected private var flowController: SicknessCertificateFlowController
    @Injected private var healthRepository: HealthRepository

    weak var coordinator: SicknessCertificateStatusReportCoordinator?

    var agreesToTerms = false

    var isValid: Bool {
        agreesToTerms
    }

    init(with coordinator: SicknessCertificateStatusReportCoordinator) {
        self.coordinator = coordinator
    }

    func goToNext(completion: @escaping () -> Void) {
        guard isValid else {
            return
        }

        flowController.submit { [weak self] result in
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
                self?.healthRepository.setProvenSick()
                self?.coordinator?.showConfirmation()
            default:
                break
            }
        }
    }
}
