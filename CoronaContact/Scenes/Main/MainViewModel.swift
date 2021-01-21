//
//  MainViewModel.swift
//  CoronaContact
//

import ExposureNotification
import Foundation
import Resolver

class MainViewModel: ViewModel {
    @Injected private var notificationService: NotificationService
    @Injected private var repository: HealthRepository
    @Injected private var localStorage: LocalStorage
    @Injected private var exposureService: ExposureManager
    private var observers = [NSObjectProtocol]()

    weak var coordinator: MainCoordinator?
    weak var viewController: MainViewController?

    var automaticHandshakePaused: Bool {
        exposureService.exposureNotificationStatus == .bluetoothOff
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
        exposureService.exposureNotificationStatus == .active
    }

    var isBackgroundHandshakeDisabled: Bool {
        exposureService.authorizationStatus != .authorized || localStorage.backgroundHandshakeDisabled
    }

    var isUnderSelfMonitoring: Bool {
        if case .isUnderSelfMonitoring = repository.userHealthStatus {
            return true
        }

        return false
    }

    var hasAttestedSickness: Bool {
        repository.hasAttestedSickness
    }

    var isProbablySick: Bool {
        repository.isProbablySick
    }

    var revocationStatus: RevocationStatus? {
        repository.revocationStatus
    }

    var contactHealthStatus: ContactHealthStatus? {
        repository.contactHealthStatus
    }

    var userHealthStatus: UserHealthStatus {
        repository.userHealthStatus
    }

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

        repository.$infectionWarnings
            .subscribe { [weak self] _ in
                self?.updateView()
            }
            .add(to: &subscriptions)
    }

    deinit {
        for observer in observers {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    private func registerObservers() {
        observers.append(localStorage.$attestedSicknessAt.addObserver(using: updateView))
        observers.append(localStorage.$isProbablySickAt.addObserver(using: updateView))
        observers.append(localStorage.$isUnderSelfMonitoring.addObserver(using: updateView))
        let center = NotificationCenter.default
        observers.append(center.addObserver(forName: ExposureManager.authorizationStatusChangedNotification,
                                            object: nil,
                                            queue: nil,
                                            using: updateViewByNotification))
        observers.append(center.addObserver(forName: ExposureManager.notificationStatusChangedNotification,
                                            object: nil,
                                            queue: nil,
                                            using: updateViewByNotification))
    }

    func onboardingJustFinished() {
        notificationService.askForPermissions()
        exposureService.enableExposureNotifications(true)
    }

    func removeRevocationStatus() {
        repository.removeRevocationStatus()
        updateView()
    }

    func viewWillAppear() {
        repository.refresh()
    }

    func updateView() {
        viewController?.updateView()
    }

    private func updateViewByNotification(_: Notification) {
        updateView()
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
            selfTestingTapped()
        default:
            break
        }
    }

    func tappedTertiaryButtonInUserHealthStatus() {
        switch repository.userHealthStatus {
        case .isProbablySick:
            sicknessCertificateTapped()
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

    func selfTestingTapped() {
        localStorage.hasSymptomsOrPositiveAttestAt = nil
        coordinator?.selfTesting(updateKeys: false)
    }
    
    func coronaSuspicionButtonTapped() {
        coordinator?.openCoronaSuspicionController()
    }

    func uploadMissingPobablySickKeys() {
        coordinator?.selfTesting(updateKeys: true)
    }

    func uploadMissingAttestedSickKeys() {
        coordinator?.openSicknessCertificateController(updateKeys: true)
    }

    func sicknessCertificateTapped() {
        localStorage.hasSymptomsOrPositiveAttestAt = nil
        coordinator?.openSicknessCertificateController(updateKeys: false)
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
        exposureService.enableExposureNotifications(enable) { [weak self] error in
            if let error = error as? ENError, error.code == .notAuthorized {
                self?.coordinator?.showMissingPermissions(type: .exposureFramework)
            }
        }
    }
}
