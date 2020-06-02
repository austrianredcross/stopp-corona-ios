//
//  SelfTestingPersonalDataCoordinator.swift
//  CoronaContact
//

import UIKit

final class SelfTestingPersonalDataCoordinator: Coordinator, ErrorPresentableCoordinator {
    lazy var rootViewController: SelfTestingPersonalDataViewController = {
        SelfTestingPersonalDataViewController.instantiate()
    }()

    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    override func start() {
        rootViewController.viewModel = SelfTestingPersonalDataViewModel(with: self)
        navigationController.pushViewController(rootViewController, animated: true)
    }

    override func finish(animated: Bool = false) {}

    func tanConfirmation() {
        let child = SelfTestingTanConfirmationCoordinator(navigationController: navigationController)
        addChildCoordinator(child)
        child.start()
    }
}
