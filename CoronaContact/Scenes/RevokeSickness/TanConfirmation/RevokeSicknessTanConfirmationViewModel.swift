//
//  RevokeSicknessTanConfirmationViewModel.swift
//  CoronaContact
//

import Foundation
import Resolver

class RevokeSicknessTanConfirmationViewModel: ViewModel {
    @Injected private var flowController: RevokeSicknessFlowController

    weak var coordinator: RevokeSicknessTanConfirmationCoordinator?

    var mobileNumber: String? {
        flowController.personalData?.mobileNumber
    }

    var composeTanNumber: (() -> String?)?

    init(with coordinator: RevokeSicknessTanConfirmationCoordinator) {
        self.coordinator = coordinator
    }

    func resendTan(completion: @escaping () -> Void) {
        guard let personalData = flowController.personalData else {
            return
        }

        flowController.tanConfirmation(personalData: personalData) { [weak self] result in
            completion()

            switch result {
            case let .failure(.tanConfirmation(error)):
                self?.coordinator?.showErrorAlert(title: error.title, error: error.description)
            case .success:
                break
            default:
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
