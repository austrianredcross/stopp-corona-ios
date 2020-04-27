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

        personalData.warning = .green

        flowController.tanConfirmation(personalData: personalData) { [weak self] result in
            completion()

            switch result {
            case .failure(let error):
                self?.coordinator?.showErrorAlert(title: error.title, error: error.description)
            case .success:
                self?.coordinator?.tanConfirmation()
            }
        }
    }

    func viewClosed() {
        coordinator?.finish()
    }
}
