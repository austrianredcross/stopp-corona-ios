//
//  SicknessCertificatePersonalDataCoordinator.swift
//  CoronaContact
//

import UIKit

final class SicknessCertificatePersonalDataCoordinator: Coordinator, ErrorPresentableCoordinator {
    lazy var rootViewController: SicknessCertificatePersonalDataViewController = {
        SicknessCertificatePersonalDataViewController.instantiate()
    }()

    let updateKeys: Bool
    var navigationController: UINavigationController

    init(navigationController: UINavigationController, updateKeys: Bool) {
        self.updateKeys = updateKeys
        self.navigationController = navigationController
    }

    override func start() {
        rootViewController.viewModel = SicknessCertificatePersonalDataViewModel(with: self, updateKeys: updateKeys)
        navigationController.pushViewController(rootViewController, animated: true)
    }

    override func finish(animated: Bool = false) {
        // if the viewController is still here this call came from the parent and we need to remove it
        if rootViewController.parent == navigationController {
            navigationController.popViewController(animated: false)
        }
        parentCoordinator?.didFinish(self)
    }

    func tanConfirmation() {
        let child = SicknessCertificateTanConfirmationCoordinator(navigationController: navigationController, updateKeys: updateKeys)
        addChildCoordinator(child)
        child.start()
    }
}
