//
//  OnboardingCoordinator.swift
//  CoronaContact
//

import UIKit

class ContactCoordinator: Coordinator, ShareSheetPresentable {
    var navigationController: UINavigationController

    lazy var rootViewController: ContactViewController = {
        ContactViewController.instantiate()
    }()

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    override func start() {
        rootViewController.viewModel = ContactViewModel(with: self)
        navigationController.pushViewController(rootViewController, animated: true)
    }

    override func finish(animated: Bool = false) {
        if rootViewController.parent == navigationController {
            navigationController.popViewController(animated: false)
        }
        parentCoordinator?.didFinish(self)
    }

    func showHelp() {
        let child = ContactHelpCoordinator(navigationController: navigationController)
        addChildCoordinator(child)
        child.start()
    }

    func shareApp() {
        presentShareAppActivity()
    }

    func microphoneInfo() {
        let child = MicrophoneInfoCoordinator(navigationController: navigationController)
        addChildCoordinator(child)
        child.start()
    }
}
