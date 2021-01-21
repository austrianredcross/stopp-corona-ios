//
//  SelfTestingCoronaSuspicionCoordinator.swift
//  CoronaContact
//

import UIKit

final class SelfTestingCoronaSuspicionCoordinator: Coordinator {
    lazy var rootViewController: SelfTestingCoronaSuspicionViewController = {
        SelfTestingCoronaSuspicionViewController.instantiate()
    }()
    
    var navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    override func start() {
        rootViewController.viewModel = SelfTestingCoronaSuspicionViewModel(with: self)
        navigationController.pushViewController(rootViewController, animated: true)
    }
    
    override func finish(animated: Bool = false) {
        navigationController.popToRootViewController(animated: true)
        parentCoordinator?.didFinish(self)
    }
}
