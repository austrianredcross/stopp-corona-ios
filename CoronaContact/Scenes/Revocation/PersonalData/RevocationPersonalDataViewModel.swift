//
//  RevocationPersonalDataViewModel.swift
//  CoronaContact
//

import Foundation
import Resolver

class RevocationPersonalDataViewModel: ViewModel {
    @Injected private var flowController: RevocationFlowController
    @Injected private var localStorage: LocalStorage

    weak var coordinator: RevocationPersonalDataCoordinator?

    var composePersonalData: (() -> PersonalData?)?
    
    var personalDataDescription: String {
        let calculationStartDate = (localStorage.isProbablySickAt ?? Date()).addDays(-2)
        let dayDifference = calculationStartDate?.days(until: Date())
        return String(format: "revocation_personal_data_description".localized, "\(dayDifference ?? 2)")
    }

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
