//
//  ContactHelpCoordinator.swift
//  CoronaContact
//

import UIKit

final class ContactHelpCoordinator: Coordinator {

    lazy var rootViewController: ContactHelpViewController = {
        ContactHelpViewController.instantiate()
    }()

    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    override func start() {
        rootViewController.viewModel = ContactHelpViewModel(with: self)
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
