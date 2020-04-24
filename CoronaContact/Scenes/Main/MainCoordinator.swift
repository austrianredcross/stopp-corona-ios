//
//  MainCoordinator.swift
//  CoronaContact
//

import UIKit
import Resolver

class MainCoordinator: Coordinator {
    var navigationController: UINavigationController

    @Injected private var notificationService: NotificationService
    @Injected private var p2pkit: P2PKitService
    private weak var mainViewModel: MainViewModel?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func contacts() {
        let child = ContactCoordinator(navigationController: navigationController)
        addChildCoordinator(child)
        child.start()
    }

    func help() {
        let child = MainHelpCoordinator(navigationController: navigationController)
        addChildCoordinator(child)
        child.start()
    }

    func onboarding() {
        let child = OnboardingCoordinator(navigationController: navigationController)
        addChildCoordinator(child)
        child.start(context: .legal)
    }

    func startMenu() {
        let child = StartMenuCoordinator(navigationController: navigationController)
        addChildCoordinator(child)
        child.start()
    }

    func selfTesting() {
        let child = SelfTestingCoordinator(navigationController: navigationController)
        addChildCoordinator(child)
        child.start()
    }

    func sicknessCertificate() {
        let child = SicknessCertificateCoordinator(navigationController: navigationController)
        addChildCoordinator(child)
        child.start()
    }

    func attestedSicknessGuidelines() {
        let child = AttestedSicknessGuidelinesCoordinator(navigationController: navigationController)
        addChildCoordinator(child)
        child.start()
    }

    func suspicionGuidelines(with healthStatus: UserHealthStatus) {
        let child = SuspicionGuidelinesCoordinator(navigationController: navigationController)
        addChildCoordinator(child)
        child.start()

        let viewModel = child.rootViewController.viewModel

        viewModel?.userHealthStatus = healthStatus
    }

    func selfMonitoringGuidelines() {
        let child = SelfMonitoringGuidelinesCoordinator(navigationController: navigationController)
        addChildCoordinator(child)
        child.start()
    }

    func showMissingPermissions(type: MissingPermissionsCoordinator.PermissionType) {
        let child = MissingPermissionsCoordinator(type: type, navigationController: navigationController)
        addChildCoordinator(child)
        child.start()
    }

    func revocation() {
        let child = RevocationPersonalDataCoordinator(navigationController: navigationController)
        addChildCoordinator(child)
        child.start()
    }

    func contactSickness(with healthStatus: ContactHealthStatus, infectionWarnings: [InfectionWarning]) {
        let child = ContactSicknessCoordinator(navigationController: navigationController)
        addChildCoordinator(child)
        child.start()

        let viewModel = child.rootViewController.viewModel

        viewModel?.contactHealthStatus = healthStatus
        viewModel?.infectionWarnings = infectionWarnings
    }

    func history() {
        let child = HistoryCoordinator(navigationController: navigationController)
        addChildCoordinator(child)
        child.start()
    }

    override func start() {
        let viewModel = MainViewModel(with: self)
        let viewController = MainViewController.instantiate(with: viewModel)

        mainViewModel = viewModel
        navigationController.pushViewController(viewController, animated: false)

        if !UserDefaults.standard.hasSeenOnboarding {
            DispatchQueue.main.async { self.onboarding() }
        } else {
            notificationService.dismissAllNotifications()
        }
    }

    override func didFinish(_ coordinator: Coordinator) {
        if coordinator is OnboardingCoordinator {
            mainViewModel?.onboardingJustFinished()
        }
        super.didFinish(coordinator)
    }
}
