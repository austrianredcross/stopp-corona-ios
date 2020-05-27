//
//  MainViewModel.swift
//  CoronaContact
//

import Foundation
import Resolver

class MainViewModel: ViewModel {

    @Injected private var notificationService: NotificationService

    @Injected private var repository: HealthRepository

    weak var coordinator: MainCoordinator?
    weak var viewController: MainViewController?

    var automaticHandshakePaused: Bool {
        // TODO: new implementation
        return false
    }

    var displayNotifications: Bool {
        displayHealthStatus || repository.revocationStatus != nil
    }
    var displayHealthStatus: Bool {
        repository.isProbablySick
            || repository.hasAttestedSickness
            || isUnderSelfMonitoring
            || repository.contactHealthStatus != nil
    }
    var backgroundServiceActive: Bool {
        // TODO: new implementation
        return false
    }
    var isBackgroundHandshakeActive: Bool { !UserDefaults.standard.backgroundHandShakeDisabled }

    var isUnderSelfMonitoring: Bool {
        if case .isUnderSelfMonitoring = repository.userHealthStatus {
            return true
        }

        return false
    }

    var hasAttestedSickness: Bool { repository.hasAttestedSickness }
    var isProbablySick: Bool { repository.isProbablySick }
    var revocationStatus: RevocationStatus? { repository.revocationStatus }
    var contactHealthStatus: ContactHealthStatus? { repository.contactHealthStatus }
    var userHealthStatus: UserHealthStatus { repository.userHealthStatus }
    var numberOfContacts: Int { repository.numberOfContacts }

    private var subscriptions: Set<AnySubscription> = []

    init(with coordinator: MainCoordinator) {
        self.coordinator = coordinator

        registerObservers()

        repository.$revocationStatus
            .subscribe { [weak self] _ in
                self?.updateView()
            }
            .add(to: &subscriptions)

        repository.$userHealthStatus
            .subscribe { [weak self] _ in
                self?.updateView()
            }
            .add(to: &subscriptions)

        repository.$numberOfContacts
            .subscribe { [weak self] _ in
                self?.updateView()
            }
            .add(to: &subscriptions)

        repository.$infectionWarnings
            .subscribe { [weak self] _ in
                self?.updateView()
            }
            .add(to: &subscriptions)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func registerObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(checkNewContact),
                                               name: .DatabaseServiceNewContact,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(checkNewSickContacts),
                                               name: .DatabaseServiceNewSickContact,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateView),
                                               name: .DatabaseSicknessUpdated,
                                               object: nil)
    }

    func onboardingJustFinished() {
        notificationService.askForPermissions()
    }

    func removeRevocationStatus() {
        repository.removeRevocationStatus()
        updateView()
    }

    @objc func viewWillAppear() {
        checkNewContact()
        checkNewSickContacts()
        repository.refresh()
    }

    @objc func updateView() {
        viewController?.updateView()
    }

    @objc func checkNewContact() {
        repository.checkNewContact()
    }

    @objc func checkNewSickContacts() {
        repository.checkNewSickContacts()
    }

    func tappedPrimaryButtonInUserHealthStatus() {
        switch repository.userHealthStatus {
        case .isProbablySick:
            coordinator?.suspicionGuidelines(with: repository.userHealthStatus)
        case .isUnderSelfMonitoring:
            coordinator?.selfMonitoringGuidelines()
        case .hasAttestedSickness:
            coordinator?.attestedSicknessGuidelines()
        default:
            break
        }
    }

    func tappedSecondaryButtonInUserHealthStatus() {
        switch repository.userHealthStatus {
        case .hasAttestedSickness:
            revokeSickness()
        case .isProbablySick:
            revocation()
        case .isUnderSelfMonitoring:
            selfTesting()
        default:
            break
        }
    }

    func tappedTertiaryButtonInUserHealthStatus() {
        switch repository.userHealthStatus {
        case .isProbablySick:
            sicknessCertificate()
        default:
            break
        }
    }

    func help() {
        coordinator?.help()
    }

    func onboarding() {
        coordinator?.onboarding()
    }

    func startMenu() {
        coordinator?.startMenu()
    }

    func shareApp() {
        coordinator?.shareApp()
    }

    func selfTesting() {
        coordinator?.selfTesting()
    }

    func sicknessCertificate() {
        coordinator?.sicknessCertificate()
    }

    func attestedSicknessGuidelines() {
        coordinator?.attestedSicknessGuidelines()
    }

    func revokeSickness() {
        coordinator?.revokeSickness()
    }

    func revocation() {
        coordinator?.revocation()
    }

    func contactSickness(with healthStatus: ContactHealthStatus) {
        if hasAttestedSickness {
            coordinator?.attestedSicknessGuidelines()
        } else {
            coordinator?.contactSickness(with: healthStatus, infectionWarnings: repository.infectionWarnings)
        }
    }

    func backgroundDiscovery(enable: Bool) {
       // TODO: new implementation
    }
}
