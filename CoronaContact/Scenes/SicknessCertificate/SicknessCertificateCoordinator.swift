//
//  SicknessCertificateCoordinator.swift
//  CoronaContact
//

import UIKit

final class SicknessCertificateCoordinator: Coordinator {

    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    override func start() {
        let child = SicknessCertificatePersonalDataCoordinator(navigationController: navigationController)
        addChildCoordinator(child)
        child.start()
    }

    override func didFinish(_ coordinator: Coordinator) {
        super.didFinish(coordinator)
        parentCoordinator?.didFinish(self)
    }
}
