//
//  SicknessCertificateStatusReportViewModel.swift
//  CoronaContact
//

import Foundation
import Resolver

class SicknessCertificateStatusReportViewModel: ViewModel {
    @Injected private var flowController: SicknessCertificateFlowController
    @Injected private var healthRepository: HealthRepository
    @Injected private var localStorage: LocalStorage

    weak var coordinator: SicknessCertificateStatusReportCoordinator?
    let updateKeys: Bool

    var agreesToTerms = false

    var isValid: Bool {
        agreesToTerms
    }

    init(with coordinator: SicknessCertificateStatusReportCoordinator, updateKeys: Bool) {
        self.coordinator = coordinator
        self.updateKeys = updateKeys
    }

    func goToNext(completion: @escaping () -> Void) {
        guard isValid else {
            return
        }

        var startDate = Date().addDays(-3)!
        if let isProbablySickAt = localStorage.isProbablySickAt {
            startDate = isProbablySickAt.addDays(-3)!
        }
        var endDate = Date()

        if updateKeys {
            if let missingUploadedKeysAt = localStorage.missingUploadedKeysAt {
                startDate = missingUploadedKeysAt
                endDate = missingUploadedKeysAt
            }
        }

        flowController.submit(from: startDate, untilIncluding: endDate) { [weak self] result in
            guard let self = self else { return }
            completion()

            switch result {
            case let .failure(.submission(error)):
                self.coordinator?.showErrorAlert(
                    title: error.displayableError.title,
                    error: error.displayableError.description,
                    closeAction: { _ in
                        if error.personalDataInvalid {
                            self.coordinator?.goBackToPersonalData()
                        } else if error.tanInvalid {
                            self.coordinator?.goBackToTanConfirmation()
                        }
                    }
                )
            case .success:
                if self.updateKeys {
                    self.localStorage.missingUploadedKeysAt = nil
                } else {
                    self.healthRepository.setProvenSick()
                }
                self.coordinator?.showConfirmation()
            default:
                break
            }
        }
    }
}
