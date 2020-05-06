//
//  RevokeSicknessTanConfirmationCoordinator.swift
//  CoronaContact
//

import UIKit

final class RevokeSicknessTanConfirmationCoordinator: Coordinator, ErrorPresentableCoordinator {

    lazy var rootViewController: RevokeSicknessTanConfirmationViewController = {
        RevokeSicknessTanConfirmationViewController.instantiate()
    }()

    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    override func start() {
        rootViewController.viewModel = RevokeSicknessTanConfirmationViewModel(with: self)
        navigationController.pushViewController(rootViewController, animated: true)
    }

    override func finish(animated: Bool = false) {
        navigationController.popViewController(animated: animated)
    }

    func reportStatus() {
        let child = RevokeSicknessStatusReportCoordinator(navigationController: navigationController)
        addChildCoordinator(child)
        child.start()
    }
}
