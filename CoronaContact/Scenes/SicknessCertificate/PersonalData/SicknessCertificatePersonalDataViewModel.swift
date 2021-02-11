//
//  SicknessCertificatePersonalDataViewModel.swift
//  CoronaContact
//

import Foundation
import Resolver

class SicknessCertificatePersonalDataViewModel: ViewModel {
    @Injected private var flowController: SicknessCertificateFlowController
    @Injected private var localStorage: LocalStorage

    weak var coordinator: SicknessCertificatePersonalDataCoordinator?

    var composePersonalData: (() -> PersonalData?)?
    
    var personalDataDescription: String {
        let calculationStartDate = (localStorage.hasSymptomsOrPositiveAttestAt ?? Date()).addDays(-2)
        let dayDifference = calculationStartDate?.days(until: Date())
        return String(format: "sickness_certificate_personal_data_description".localized, "\(dayDifference ?? 2)")
    }

    init(with coordinator: SicknessCertificatePersonalDataCoordinator) {
        self.coordinator = coordinator
    }

    func goToNext(completion: @escaping () -> Void) {
        guard var personalData = composePersonalData?() else {
            return
        }

        personalData.diagnosisType = .red

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
        localStorage.hasSymptomsOrPositiveAttestAt = nil
        coordinator?.finish()
    }
}
