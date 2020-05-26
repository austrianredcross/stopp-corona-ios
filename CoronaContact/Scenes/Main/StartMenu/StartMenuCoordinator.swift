//
//  StartMenuCoordinator.swift
//  CoronaContact
//

import UIKit
import Carte

class StartMenuCoordinator: Coordinator, ShareSheetPresentable {
    var navigationController: UINavigationController

    lazy var rootViewController: StartMenuViewController = {
        StartMenuViewController.instantiate()
    }()

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    override func start() {
        rootViewController.viewModel = StartMenuViewModel(with: self)
        navigationController.pushViewController(rootViewController, animated: true)
    }

    func contacts() {
        let child = ContactCoordinator(navigationController: navigationController)
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

    func revokeSickness() {
        let child = RevokeSicknessPersonalDataCoordinator(navigationController: navigationController)
        addChildCoordinator(child)
        child.start()
    }

    func shareApp() {
        presentShareAppActivity()
    }

    func openOnboarding() {
        let child = OnboardingCoordinator(navigationController: navigationController)
        addChildCoordinator(child)
        child.start(context: .regular)
    }

    func openSavedIDs() {
        let child = SavedIDsCoordinator(navigationController: navigationController)
        addChildCoordinator(child)
        child.start()
    }

    func openLicences() {
        let carteViewController = CarteViewController()
        navigationController.pushViewController(carteViewController, animated: true)
    }

    func openImprint() {
        let child = StartMenuSimpleWebViewCoordinator(navigationController: navigationController)
        addChildCoordinator(child)
        child.start()

        child.rootViewController.viewModel?.website = .imprint
    }

    func openPrivacy() {
        let child = StartMenuSimpleWebViewCoordinator(navigationController: navigationController)
        addChildCoordinator(child)
        child.start()

        child.rootViewController.viewModel?.website = .privacyAndTermsOfUse
    }

    override func finish(animated: Bool = false) {
        if rootViewController.parent == navigationController {
            navigationController.popViewController(animated: true)
        }
        parentCoordinator?.didFinish(self)
    }
}
