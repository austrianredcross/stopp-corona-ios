//
//  DiaryAddEntryCoordinator.swift
//  CoronaContact
//

import UIKit

class DiaryAddEntryCoordinator: Coordinator {
    
    private lazy var rootViewController: DiaryAddEntryViewController = {
        let controller = DiaryAddEntryViewController.instantiate()
        return controller
    }()
    
    let presentingViewController: UIViewController
    let saveEntryDate: Date
    
    init(presentingViewController: UIViewController, selectedDate: Date) {
        self.presentingViewController = presentingViewController
        self.saveEntryDate = selectedDate
    }
    
    override func start() {
        rootViewController.modalPresentationStyle = .overFullScreen
        rootViewController.view.backgroundColor = .ccPopUpBackground
        let viewModel = DiaryAddEntryViewModel(coordinator: self, viewController: rootViewController, saveEntityDate: saveEntryDate)
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
