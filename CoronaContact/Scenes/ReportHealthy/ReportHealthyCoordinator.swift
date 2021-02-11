//
//  ReportHealthyCoordinator.swift
//  CoronaContact
//

import Foundation
import UIKit

class ReportHealthyCoordinator: Coordinator {
    private lazy var rootViewController: ReportHealthyViewController = {
        let controller = ReportHealthyViewController.instantiate()
        return controller
    }()
    
    let presentingViewController: UIViewController
    
    init(presentingViewController: UIViewController) {
        self.presentingViewController = presentingViewController
    }
    
    override func start() {
        rootViewController.modalPresentationStyle = .overFullScreen
        rootViewController.providesPresentationContextTransitionStyle = true
        rootViewController.definesPresentationContext = true
        rootViewController.view.backgroundColor = .ccPopUpBackground
        let viewModel = ReportHealthyViewModel()
        viewModel.coordinator = self
        rootViewController.viewModel = viewModel
        presentingViewController.present(rootViewController, animated: true, completion: nil)
    }
    
    func dismiss() {
        rootViewController.dismiss(animated: true, completion: {
            self.finish()
        })
    }
    
    override func finish(animated: Bool = false) {
        parentCoordinator?.didFinish(self)
    }
}
