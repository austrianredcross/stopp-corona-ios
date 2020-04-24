//
//  SelfTestingStatusReportViewModel.swift
//  CoronaContact
//

import Foundation
import Resolver

class SelfTestingStatusReportViewModel: ViewModel {

    @Injected private var flowController: SelfTestingReportFlowController

    weak var coordinator: SelfTestingStatusReportCoordinator?

    var agreesToTerms = false

    var isValid: Bool {
        agreesToTerms
    }

    init(with coordinator: SelfTestingStatusReportCoordinator) {
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
}
