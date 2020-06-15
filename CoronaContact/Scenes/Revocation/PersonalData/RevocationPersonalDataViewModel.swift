//
//  RevocationPersonalDataViewModel.swift
//  CoronaContact
//

import Foundation
import Resolver

class RevocationPersonalDataViewModel: ViewModel {
    @Injected private var flowController: RevocationFlowController

    weak var coordinator: RevocationPersonalDataCoordinator?

    var composePersonalData: (() -> PersonalData?)?

    init(with coordinator: RevocationPersonalDataCoordinator) {
        self.coordinator = coordinator
    }

    func goToNext(completion: @escaping () -> Void) {
        guard var personalData = composePersonalData?() else {
            return
        }

        personalData.diagnosisType = .green

        flowController.tanConfirmation(personalData: personalData) { [weak self] result in
            completion()

            switch result {
            case let .failure(.tanConfirmation(error)):
                self?.coordinator?.showErrorAlert(title: error.title, error: error.description)
            case .success:
                self?.coordinator?.tanConfirmation()
            default:
                break
            }
        }
    }

    func viewClosed() {
        coordinator?.finish()
    }
}
