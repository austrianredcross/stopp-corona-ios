//
//  MainCoordinator.swift
//  CoronaContact
//

import UIKit
import Resolver

class MainCoordinator: Coordinator, ShareSheetPresentable {

    var navigationController: UINavigationController
    var rootViewController: UIViewController {
        navigationController
    }

    @Injected private var notificationService: NotificationService
    @Injected private var localStorage: LocalStorage
    private weak var mainViewModel: MainViewModel?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
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

    func shareApp() {
        presentShareAppActivity()
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

    func revokeSickness() {
        let child = RevokeSicknessPersonalDataCoordinator(navigationController: navigationController)
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

    override func start() {
        let viewModel = MainViewModel(with: self)
        let viewController = MainViewController.instantiate(with: viewModel)

        mainViewModel = viewModel
        navigationController.pushViewController(viewController, animated: false)

        if !localStorage.hasSeenOnboarding {
            DispatchQueue.main.async { self.onboarding() }
        } else {
            notificationService.dismissAllNotifications()
        }
    }

    override func didFinish(_ coordinator: Coordinator) {
        LoggingService.debug("didFinish \(coordinator)", context: .navigation)
        if coordinator is OnboardingCoordinator {
            mainViewModel?.onboardingJustFinished()
        }
        super.didFinish(coordinator)
    }
}
