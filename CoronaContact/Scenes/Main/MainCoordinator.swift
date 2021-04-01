//
//  MainCoordinator.swift
//  CoronaContact
//

import Resolver
import UIKit

class MainCoordinator: Coordinator, ShareSheetPresentable {
    var navigationController: UINavigationController
    var rootViewController: UIViewController {
        navigationController
    }

    @Injected private var notificationService: NotificationService
    @Injected private var localStorage: LocalStorage
    @Injected private var whatsNewRepository: WhatsNewRepository
    private weak var mainViewModel: MainViewModel?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func help() {
        let child = MainHelpCoordinator(navigationController: navigationController)
        addChildCoordinator(child)
        child.start()
    }

    func show(_ historyItem: WhatsNewContent) {
        let child = WhatsNewCoordinator(presentingController: rootViewController)
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
    
    func openCoronaSuspicionController() {
        let child = SelfTestingCoronaSuspicionCoordinator(navigationController: navigationController)
        addChildCoordinator(child)
        child.start()
    }

    func openSicknessCertificateController() {
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
    
    func reportHealthyButtonPressed() {
        let child = ReportHealthyCoordinator(presentingViewController: rootViewController)
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
    
    func showInteroperabilityController() {
        let child = InteroperabilityCoordinator(navigationController: navigationController)
        addChildCoordinator(child)
        child.start()
    }
    
    func diaryFaq() {
        let child = DiaryFaqCoordinator(navigationController: navigationController)
        addChildCoordinator(child)
        child.start()
    }
    
    func diary() {
        let child = DiaryOverviewCoordinator(navigationController: navigationController)
        addChildCoordinator(child)
        child.start()
    }

    override func start() {
        let viewModel = MainViewModel(with: self)
        let viewController = MainViewController.instantiate(with: viewModel)

        mainViewModel = viewModel
        navigationController.pushViewController(viewController, animated: false)
                        
        if !localStorage.hasSeenOnboarding {
            DispatchQueue.main.async {
                // Don't show "What's New" for new installations:
                self.whatsNewRepository.markAsSeen()
                self.onboarding()
            }
        } else if !localStorage.hasBeenAgreedInteroperability {
            DispatchQueue.main.async {
                self.showInteroperabilityController()
            }
        } else {
            notificationService.dismissAllNotifications()
            DispatchQueue.main.async {
                if self.whatsNewRepository.isWhatsNewAvailable,
                    let latestHistoryItem = self.whatsNewRepository.newHistoryItems.last
                {
                    self.show(latestHistoryItem)
                    self.whatsNewRepository.markAsSeen()
                }
            }
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
