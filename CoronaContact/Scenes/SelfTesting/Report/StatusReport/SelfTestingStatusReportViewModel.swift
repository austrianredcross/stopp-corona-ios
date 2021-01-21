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
    let updateKeys: Bool

    var agreesToTerms = false

    var isValid: Bool {
        agreesToTerms
    }

    init(with coordinator: SelfTestingStatusReportCoordinator, updateKeys: Bool) {
        self.coordinator = coordinator
        self.updateKeys = updateKeys
    }

    func goToNext(completion: @escaping () -> Void) {
        guard isValid else {
            return
        }

        let startDayOfSymptomsOrAttest = localStorage.hasSymptomsOrPositiveAttestAt ?? Date()

        let uploadDays = configurationService.currentConfig.uploadKeyDays
        var startDate = startDayOfSymptomsOrAttest.addDays(-uploadDays)!
        var endDate = Date()
        
        if updateKeys, let missingUploadedKeysAt = localStorage.missingUploadedKeysAt {
            startDate = missingUploadedKeysAt
            endDate = missingUploadedKeysAt
        }

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
                if self.updateKeys {
                    self.localStorage.missingUploadedKeysAt = nil
                } else {
                    self.healthRepository.setProbablySick(from: startDayOfSymptomsOrAttest)
                }
                self.coordinator?.showConfirmation()
            default:
                break
            }
        }
    }
}
