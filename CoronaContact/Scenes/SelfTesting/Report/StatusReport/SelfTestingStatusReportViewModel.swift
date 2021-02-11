//
//  SelfTestingStatusReportViewModel.swift
//  CoronaContact
//

import Foundation
import Resolver

class SelfTestingStatusReportViewModel: ViewModel {
    @Injected private var flowController: SelfTestingReportFlowController
    @Injected private var healthRepository: HealthRepository
    @Injected private var localStorage: LocalStorage
    @Injected private var configurationService: ConfigurationService

    weak var coordinator: SelfTestingStatusReportCoordinator?

    var agreesToTerms = false

    var isValid: Bool {
        agreesToTerms
    }
    
    var updateKeys: Bool {
        localStorage.missingUploadedKeysAt != nil
    }

    init(with coordinator: SelfTestingStatusReportCoordinator) {
        self.coordinator = coordinator
    }

    func goToNext(completion: @escaping () -> Void) {
        guard isValid else {
            return
        }

        let startDayOfSymptomsOrAttest = localStorage.hasSymptomsOrPositiveAttestAt ?? Date()

        let uploadDays = configurationService.currentConfig.uploadKeyDays
        let startDate = startDayOfSymptomsOrAttest.addDays(-uploadDays)!
        let endDate = Date()

        flowController.submit(from: startDate, untilIncluding: endDate, diagnosisType: .yellow) { [weak self] result in
            completion()
            guard let self = self else {
                return
            }
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
                self.healthRepository.setProbablySick(from: startDayOfSymptomsOrAttest)
                self.coordinator?.showConfirmation()
            default:
                break
            }
        }
    }
}
