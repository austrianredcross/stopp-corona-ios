//
//  MicrophoneInfoCoordinator.swift
//  CoronaContact
//

import UIKit

final class MicrophoneInfoCoordinator: Coordinator {

    lazy var rootViewController: MicrophoneInfoViewController = {
        MicrophoneInfoViewController.instantiate()
    }()

    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    override func start() {
        rootViewController.viewModel = MicrophoneInfoViewModel(with: self)
        rootViewController.modalPresentationStyle = .overFullScreen
        rootViewController.modalTransitionStyle = .crossDissolve
        navigationController.present(rootViewController, animated: true, completion: nil)
    }

    override func finish(animated: Bool = false) {
        navigationController.dismiss(animated: true, completion: nil)
        parentCoordinator?.didFinish(self)
    }

    func close() {
        finish(animated: true)
    }
}
