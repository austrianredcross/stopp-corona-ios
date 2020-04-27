//
//  OnboardingCoordinator.swift
//  CoronaContact
//

import UIKit
import Resolver

class OnboardingCoordinator: Coordinator {

    var navigationController: UINavigationController

    lazy var rootViewController: UINavigationController = {
        let controller = UINavigationController(rootViewController: onboardingViewController)
        controller.setNavigationBarHidden(true, animated: false)
        return controller
    }()

    lazy var onboardingViewController: OnboardingViewController = {
        OnboardingViewController.instantiate()
    }()

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start(context: OnboardingViewModel.Context) {
        onboardingViewController.viewModel = OnboardingViewModel(with: self, context: context)
        rootViewController.modalPresentationStyle = .fullScreen
        navigationController.present(rootViewController, animated: true, completion: nil)
    }

    override func finish(animated: Bool = false) {
        if rootViewController.presentingViewController == navigationController {
            navigationController.dismiss(animated: animated) {
                self.parentCoordinator?.didFinish(self)
            }
        } else {
            rootViewController.dismiss(animated: animated) {
                self.parentCoordinator?.didFinish(self)
            }
        }
    }

    func consent() {
        //let child = OnboardingConsentCoordinator(navigationController: rootViewController)
        //addChildCoordinator(child)
        //child.start()
    }

    func termsOfUse() {
        let child = StartMenuSimpleWebViewCoordinator(navigationController: rootViewController)
        addChildCoordinator(child)
        child.start(present: true)

        child.rootViewController.viewModel?.website = .termsOfUse
    }

    func dataPrivacy() {
        let child = StartMenuSimpleWebViewCoordinator(navigationController: rootViewController)
        addChildCoordinator(child)
        child.start(present: true)

        child.rootViewController.viewModel?.website = .privacy
    }
}
