//
//  SelfTestingConsentViewModel.swift
//  CoronaContact
//

import Foundation

class SelfTestingConsentViewModel: ViewModel {
    weak var coordinator: SelfTestingConsentCoordinator?

    var agreementToMedicalDataPrivacy = false {
        didSet {
            if agreementToMedicalDataPrivacy {
                UserDefaults.standard.agreedToMedicalDataPrivacyAt = Date()
            } else {
                UserDefaults.standard.agreedToMedicalDataPrivacyAt = nil
            }
        }
    }

    init(with coordinator: SelfTestingConsentCoordinator) {
        self.coordinator = coordinator
    }

    func consentButtonTapped() {
        guard agreementToMedicalDataPrivacy else {
            return
        }

        coordinator?.checkSymptoms()
    }

    func dataPrivacy() {
        coordinator?.dataPrivacy()
    }

    func viewClosed() {
        coordinator?.finish()
    }
}
