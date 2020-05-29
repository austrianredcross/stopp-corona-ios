//
//  SicknessCertificateTanConfirmationViewModel.swift
//  CoronaContact
//

import Foundation
import Resolver

class SicknessCertificateTanConfirmationViewModel: ViewModel {
    @Injected private var flowController: SicknessCertificateFlowController

    weak var coordinator: SicknessCertificateTanConfirmationCoordinator?

    var mobileNumber: String? {
        flowController.personalData?.mobileNumber
    }

    var composeTanNumber: (() -> String?)?

    init(with coordinator: SicknessCertificateTanConfirmationCoordinator) {
        self.coordinator = coordinator
    }

    func resendTan(completion: @escaping () -> Void) {
        guard let personalData = flowController.personalData else {
            return
        }

        flowController.tanConfirmation(personalData: personalData) { [weak self] result in
            completion()

            switch result {
            case let .failure(error):
                self?.coordinator?.showErrorAlert(title: error.title, error: error.description)
            case .success:
                break
            }
        }
    }

    func goToNext() {
        guard let tanNumber = composeTanNumber?() else {
            return
        }

        flowController.statusReport(tanNumber: tanNumber)
        coordinator?.reportStatus()
    }
}
