//
//  RevokeSicknessPersonalDataViewModel.swift
//  CoronaContact
//

import Foundation
import Resolver

class RevokeSicknessPersonalDataViewModel: ViewModel {

    @Injected private var flowController: RevokeSicknessFlowController

    weak var coordinator: RevokeSicknessPersonalDataCoordinator?

    var composePersonalData: (() -> PersonalData?)?

    init(with coordinator: RevokeSicknessPersonalDataCoordinator) {
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
