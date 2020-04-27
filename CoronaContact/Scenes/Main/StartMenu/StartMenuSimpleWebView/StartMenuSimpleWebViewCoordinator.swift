//
//  StartMenuSimpleWebViewCoordinator.swift
//  CoronaContact
//

import UIKit

final class StartMenuSimpleWebViewCoordinator: Coordinator {
    weak var wrapViewController: UINavigationController?

    lazy var rootViewController: StartMenuSimpleWebViewViewController = {
        StartMenuSimpleWebViewViewController.instantiate()
    }()

    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    override func start() {
        start(present: false)
    }

    func start(present: Bool) {
        rootViewController.viewModel = StartMenuSimpleWebViewViewModel(with: self)
        if present {
            let wrapViewController = UINavigationController(rootViewController: rootViewController)
            self.wrapViewController = wrapViewController
            navigationController.present(wrapViewController, animated: true)
        } else {
            navigationController.pushViewController(rootViewController, animated: true)
        }
    }

    override func finish(animated: Bool = false) {
        if wrapViewController != nil {
            wrapViewController?.dismiss(animated: true) {
                self.parentCoordinator?.didFinish(self)
            }
        } else {
            parentCoordinator?.didFinish(self)
        }
    }
}
