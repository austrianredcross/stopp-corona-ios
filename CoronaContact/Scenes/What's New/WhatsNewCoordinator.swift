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
    let sheetTransition = LittleSheetAnimator()

    // MARK: - Lifecycle

    init(presentingController: UIViewController) {
        self.presentingController = presentingController
    }

    // MARK: - Coordination

    override func start() {
        rootViewController.modalPresentationStyle = .overFullScreen
        rootViewController.transitioningDelegate = self
        presentingController.present(rootViewController, animated: true, completion: nil)
    }

    // MARK: - Housekeeping

    override func finish(animated: Bool = false) {
        parentCoordinator?.didFinish(self)
    }
}

// MARK: - Transition
extension WhatsNewCoordinator: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        sheetTransition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        nil
    }
}
