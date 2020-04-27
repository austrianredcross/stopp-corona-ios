//
//  SelfTestingTanConfirmationCoordinator.swift
//  CoronaContact
//

import UIKit

final class SelfTestingTanConfirmationCoordinator: Coordinator, ErrorPresentableCoordinator {

    lazy var rootViewController: SelfTestingTanConfirmationViewController = {
        SelfTestingTanConfirmationViewController.instantiate()
    }()

    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    override func start() {
        rootViewController.viewModel = SelfTestingTanConfirmationViewModel(with: self)
        navigationController.pushViewController(rootViewController, animated: true)
    }

    override func finish(animated: Bool = false) {
        navigationController.popViewController(animated: animated)
    }

    func reportStatus() {
        let child = SelfTestingStatusReportCoordinator(navigationController: navigationController)
        addChildCoordinator(child)
        child.start()
    }
}
