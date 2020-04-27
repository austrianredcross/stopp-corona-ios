//
//  MainHelpCoordinator.swift
//  CoronaContact
//

import UIKit

final class MainHelpCoordinator: Coordinator {

    lazy var rootViewController: MainHelpViewController = {
        MainHelpViewController.instantiate()
    }()

    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    override func start() {
        rootViewController.viewModel = MainHelpViewModel(with: self)
        rootViewController.modalPresentationStyle = .overFullScreen
        rootViewController.modalTransitionStyle = .crossDissolve
        navigationController.present(rootViewController, animated: true, completion: nil)
    }

    override func finish(animated: Bool = false) {
        navigationController.dismiss(animated: true, completion: nil)
        parentCoordinator?.didFinish(self)
    }

    func openFAQ() {
        ExternalWebsite.faq.openInSafariVC(from: rootViewController)
    }

    func close() {
        finish(animated: true)
    }
}
