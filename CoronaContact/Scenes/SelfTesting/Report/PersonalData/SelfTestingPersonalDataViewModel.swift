//
//  SelfTestingPersonalDataViewModel.swift
//  CoronaContact
//

import Foundation
import Resolver

class SelfTestingPersonalDataViewModel: ViewModel {

    @Injected private var flowController: SelfTestingReportFlowController

    weak var coordinator: SelfTestingPersonalDataCoordinator?

    var composePersonalData: (() -> PersonalData?)?

    init(with coordinator: SelfTestingPersonalDataCoordinator) {
        self.coordinator = coordinator
    }

    func goToNext(completion: @escaping () -> Void) {
        guard var personalData = composePersonalData?() else {
            return
        }

        personalData.warning = .yellow

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
}
