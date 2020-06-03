//
//  WhatsNewCoordinator.swift
//  CoronaContact
//

import Foundation

import UIKit

final class WhatsNewCoordinator: Coordinator {

    // MARK: - Properties

    private lazy var rootViewController: WhatsNewViewController = {
        let controller = WhatsNewViewController.instantiate()
//        controller.viewModel = SavedIDsViewModel(self)
        return controller
    }()

    let presentingController: UIViewController

    // MARK: - Lifecycle

    init(presentingController: UIViewController) {
        self.presentingController = presentingController
    }

    // MARK: - Coordination

    override func start() {
        presentingController.present(rootViewController, animated: true, completion: nil)
    }

    // MARK: - Housekeeping

    override func finish(animated: Bool = false) {
        parentCoordinator?.didFinish(self)
    }
}
