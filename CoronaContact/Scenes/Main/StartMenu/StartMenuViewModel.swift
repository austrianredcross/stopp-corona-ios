//
//  StartMenuViewModel.swift
//  CoronaContact
//

import Resolver
import UIKit

class StartMenuViewModel: ViewModel {
    weak var coordinator: StartMenuCoordinator?
    weak var viewController: StartMenuViewController?
    @Injected private var repository: HealthRepository
    private var subscriptions: Set<AnySubscription> = []

    var isFunctionsSectionHidden: Bool { repository.hasAttestedSickness }
    var isSelfTestFunctionAvailable: Bool {
        !(repository.isProbablySick || repository.hasAttestedSickness)
    }

    var canRevokeAttestedSickness: Bool { repository.userHealthStatus.canRevokeProvenSickness() }

    init(with coordinator: StartMenuCoordinator) {
        self.coordinator = coordinator

        repository.$userHealthStatus
            .subscribe { [weak self] _ in
                self?.updateView()
            }
            .add(to: &subscriptions)
    }

    func closeMenu() {
        coordinator?.finish()
    }

    func checkSymptoms() {
        coordinator?.selfTesting()
    }

    func reportPositiveDoctorsDiagnosis() {
        coordinator?.sicknessCertificate()
    }

    func revokeSickness() {
        coordinator?.revokeSickness()
    }

    func shareApp() {
        coordinator?.shareApp()
    }

    func aboutApp() {
        coordinator?.openOnboarding()
    }

    func website(_ page: ExternalWebsite) {
        page.openInSafariVC()
    }

    func openSavedIDs() {
        coordinator?.openSavedIDs()
    }

    func openSourceLicenses() {
        coordinator?.openLicences()
    }

    func dataPrivacy() {
        coordinator?.openPrivacy()
    }

    func imprint() {
        coordinator?.openImprint()
    }

    func updateView() {
        viewController?.updateView()
    }
}
