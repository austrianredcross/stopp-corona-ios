//
//  SelfTestingTanConfirmationViewModel.swift
//  CoronaContact
//

import Foundation
import Resolver

class SelfTestingTanConfirmationViewModel: ViewModel {

    @Injected private var flowController: SelfTestingReportFlowController

    weak var coordinator: SelfTestingTanConfirmationCoordinator?

    var mobileNumber: String? {
        flowController.personalData?.mobileNumber
    }

    var composeTanNumber: (() -> String?)?

    init(with coordinator: SelfTestingTanConfirmationCoordinator) {
        self.coordinator = coordinator
    }

    func resendTan(completion: @escaping () -> Void) {
        guard let personalData = flowController.personalData else {
            return
        }

        flowController.tanConfirmation(personalData: personalData) { [weak self] result in
            completion()

            switch result {
            case .failure(let error):
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
