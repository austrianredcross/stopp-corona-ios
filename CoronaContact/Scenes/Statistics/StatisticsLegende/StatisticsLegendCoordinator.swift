//
//  StatisticsLegendCoordinator.swift
//  CoronaContact
//
import Foundation
import Resolver
import UIKit

class StatisticsLegendCoordinator: Coordinator {
    
    private lazy var rootViewController: StatisticsLegendViewController = {
        let controller = StatisticsLegendViewController.instantiate()
        return controller
    }()
    
    let presentingViewController: UIViewController
    
    init(presentingViewController: UIViewController) {
        self.presentingViewController = presentingViewController
    }
    
    override func start() {
        rootViewController.modalPresentationStyle = .overFullScreen
        rootViewController.view.backgroundColor = .ccBackground
        let viewModel = StatisticsLegendViewModel(with: self)
        rootViewController.viewModel = viewModel
        presentingViewController.present(rootViewController, animated: false, completion: nil)
    }
    
    func dismiss() {
        rootViewController.dismiss(animated: true) {
            self.finish()
        }
    }
    
    override func finish(animated: Bool = false) {
        parentCoordinator?.didFinish(self)
    }
}
