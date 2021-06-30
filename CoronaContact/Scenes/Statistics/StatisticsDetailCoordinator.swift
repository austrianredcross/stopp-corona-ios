//
//  StatisticsDetailCoordinator.swift
//  CoronaContact
//

import Foundation
import Resolver
import UIKit

class StatisticsDetailCoordinator: Coordinator, ErrorPresentableCoordinator {
    lazy var rootViewController: StatisticsDetailViewController = {
        StatisticsDetailViewController.instantiate()
    }()

    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func showLegend() {
        let child = StatisticsLegendCoordinator(presentingViewController: rootViewController)
        addChildCoordinator(child)
        child.start()
    }

    override func start() {
        rootViewController.viewModel = StatisticsDetailViewModel(with: self)
        navigationController.pushViewController(rootViewController, animated: true)
    }

    override func finish(animated: Bool = false) {
        if rootViewController.parent == navigationController {
            navigationController.popViewController(animated: false)
        }
        parentCoordinator?.didFinish(self)
    }
}
