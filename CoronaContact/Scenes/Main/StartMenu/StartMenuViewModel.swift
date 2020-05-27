//
//  StartMenuViewModel.swift
//  CoronaContact
//

import UIKit
import Resolver

class StartMenuViewModel: ViewModel {

    weak var coordinator: StartMenuCoordinator?
    weak var viewController: StartMenuViewController?
    @Injected private var repository: HealthRepository
    private var subscriptions: Set<AnySubscription> = []

    var isFunctionsSectionHidden: Bool { repository.hasAttestedSickness }
    var isSelfTestFunctionAvailable: Bool {
        !(repository.isProbablySick || repository.hasAttestedSickness)
    }
    var hasAttestedSickness: Bool { repository.hasAttestedSickness }

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

    func manualHandshake() {
       // TODO: remove manual handshake from menu
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
