//
//  SelfTestingConsentCoordinator.swift
//  CoronaContact
//

import UIKit

final class SelfTestingConsentCoordinator: Coordinator {

    lazy var rootViewController: SelfTestingConsentViewController = {
        SelfTestingConsentViewController.instantiate()
    }()

    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    override func start() {
        rootViewController.viewModel = SelfTestingConsentViewModel(with: self)
        navigationController.pushViewController(rootViewController, animated: true)
    }

    override func finish(animated: Bool = false) {
        parentCoordinator?.finish(animated: animated)
        parentCoordinator?.didFinish(self)
    }

    func checkSymptoms() {
        let child = SelfTestingCheckSymptomsCoordinator(navigationController: navigationController)
        addChildCoordinator(child)
        child.start(with: 0)
    }

    func dataPrivacy() {
        let child = StartMenuSimpleWebViewCoordinator(navigationController: navigationController)
        addChildCoordinator(child)
        child.start(present: true)

        child.rootViewController.viewModel?.website = .privacy
    }
}
