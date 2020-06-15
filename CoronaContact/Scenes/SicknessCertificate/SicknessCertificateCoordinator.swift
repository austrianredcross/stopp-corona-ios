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
        start(updateKeys: false)
    }

    func start(updateKeys: Bool) {
        let child = SicknessCertificatePersonalDataCoordinator(navigationController: navigationController, updateKeys: updateKeys)
        addChildCoordinator(child)
        child.start()
    }

    override func didFinish(_ coordinator: Coordinator) {
        super.didFinish(coordinator)
        parentCoordinator?.didFinish(self)
    }
}
