//
//  DiaryDeleteCoordinator.swift
//  CoronaContact
//

import UIKit
import CoreData
import Resolver

class DiaryDeleteCoordinator: Coordinator {
    
    @Injected private var coreDataService: CoreDataService
    
    private lazy var rootViewController: DiaryDeleteViewController = {
        let controller = DiaryDeleteViewController.instantiate()
        return controller
    }()
    
    let presentingViewController: UIViewController
    let baseDiaryInformation: BaseDiaryInformation
    
    init(presentingViewController: UIViewController, baseDiaryInformation: BaseDiaryInformation) {
        self.presentingViewController = presentingViewController
        self.baseDiaryInformation = baseDiaryInformation
    }
    
    override func start() {
        rootViewController.modalPresentationStyle = .overFullScreen
        rootViewController.view.backgroundColor = .ccBackground
        let viewModel = DiaryDeleteViewModel(coordinator: self, baseDiaryInformation: baseDiaryInformation)
        rootViewController.viewModel = viewModel
        presentingViewController.present(rootViewController, animated: false, completion: nil)
    }
    
    override func finish(animated: Bool = false) {
        presentingViewController.dismiss(animated: animated, completion: nil)
    }
    
    func deletePressed() {
        coreDataService.deleteDiaryEntry(diaryEntryType: baseDiaryInformation.diaryEntryType, selectedId: baseDiaryInformation.encounterId) { [weak self] in
            self?.finish()
        }
    }
}
