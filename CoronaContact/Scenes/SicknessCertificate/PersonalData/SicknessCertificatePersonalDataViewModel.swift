//
//  SicknessCertificatePersonalDataViewModel.swift
//  CoronaContact
//

import Foundation
import Resolver

class SicknessCertificatePersonalDataViewModel: ViewModel {

    @Injected private var flowController: SicknessCertificateFlowController

    weak var coordinator: SicknessCertificatePersonalDataCoordinator?

    var composePersonalData: (() -> PersonalData?)?

    init(with coordinator: SicknessCertificatePersonalDataCoordinator) {
        self.coordinator = coordinator
    }

    func goToNext(completion: @escaping () -> Void) {
        guard var personalData = composePersonalData?() else {
            return
        }

        personalData.warning = .red

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
        self.coordinator?.finish()
    }
}
