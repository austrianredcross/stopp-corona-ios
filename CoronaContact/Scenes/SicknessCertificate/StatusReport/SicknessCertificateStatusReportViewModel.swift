//
//  SicknessCertificateStatusReportViewModel.swift
//  CoronaContact
//

import Foundation
import Resolver

class SicknessCertificateStatusReportViewModel: ViewModel {
    @Injected private var flowController: SicknessCertificateFlowController
    @Injected private var healthRepository: HealthRepository
    @Injected private var localStorage: LocalStorage
    @Injected private var configurationService: ConfigurationService

    weak var coordinator: SicknessCertificateStatusReportCoordinator?

    var agreesToTerms = false

    var isValid: Bool {
        agreesToTerms
    }
    
    var updateKeys: Bool {
        localStorage.missingUploadedKeysAt != nil
    }

    init(with coordinator: SicknessCertificateStatusReportCoordinator) {
        self.coordinator = coordinator
    }
    
    func goToNext(completion: @escaping () -> Void) {
        guard isValid else {
            return
        }
        
        let uploadDays = configurationService.currentConfig.uploadKeyDays
        let startDayOfSymptomsOrAttest = localStorage.hasSymptomsOrPositiveAttestAt ?? Date()
        var startDate = startDayOfSymptomsOrAttest.addDays(-uploadDays)!
        
        if let isProbablySickAt = localStorage.isProbablySickAt {
            startDate = isProbablySickAt.addDays(-uploadDays)!
        }
        
        let endDate = Date()

        flowController.submit(from: startDate, untilIncluding: endDate, diagnosisType: .red) { [weak self] result in
            guard let self = self else {
                return
            }
            completion()

            switch result {
            case let .failure(.submission(error)):
                self.coordinator?.showErrorAlert(
                    title: error.displayableError.title,
                    error: error.displayableError.description,
                    closeAction: { _ in
                        if error.personalDataInvalid {
                            self.coordinator?.goBackToPersonalData()
                        } else if error.tanInvalid {
                            self.coordinator?.goBackToTanConfirmation()
                        }
                    }
                )
            case .success:
                self.healthRepository.setProvenSick(from: self.localStorage.isProbablySick ? self.localStorage.isProbablySickAt! : startDayOfSymptomsOrAttest)
                self.coordinator?.showConfirmation()
            default:
                break
            }
        }
    }
}
