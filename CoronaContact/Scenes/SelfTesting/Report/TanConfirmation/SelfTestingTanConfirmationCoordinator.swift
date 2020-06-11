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
    let updateKeys: Bool

    init(navigationController: UINavigationController, updateKeys: Bool) {
        self.navigationController = navigationController
        self.updateKeys = updateKeys
    }

    override func start() {
        rootViewController.viewModel = SelfTestingTanConfirmationViewModel(with: self)
        navigationController.pushViewController(rootViewController, animated: true)
    }

    override func finish(animated: Bool = false) {
        navigationController.popViewController(animated: animated)
    }

    func reportStatus() {
        let child = SelfTestingStatusReportCoordinator(navigationController: navigationController, updateKeys: updateKeys)
        addChildCoordinator(child)
        child.start()
    }
}
