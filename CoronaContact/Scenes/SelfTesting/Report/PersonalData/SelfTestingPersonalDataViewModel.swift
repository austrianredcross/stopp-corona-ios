//
//  SelfTestingPersonalDataViewModel.swift
//  CoronaContact
//

import Foundation
import Resolver

class SelfTestingPersonalDataViewModel: ViewModel {
    @Injected private var flowController: SelfTestingReportFlowController
    @Injected private var localStorage: LocalStorage

    weak var coordinator: SelfTestingPersonalDataCoordinator?

    var composePersonalData: (() -> PersonalData?)?
    
    var personalDataDescription: String {
        let calculationStartDate = (localStorage.hasSymptomsOrPositiveAttestAt ?? Date()).addDays(-2)
        let dayDifference = calculationStartDate?.days(until: Date())
        return String(format: "self_testing_personal_data_description".localized, "\(dayDifference ?? 2)")
    }

    init(with coordinator: SelfTestingPersonalDataCoordinator) {
        self.coordinator = coordinator
    }

    func goToNext(completion: @escaping () -> Void) {
        guard var personalData = composePersonalData?() else {
            return
        }

        personalData.diagnosisType = .yellow

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
}
