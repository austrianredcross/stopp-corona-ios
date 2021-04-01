//
//  DiaryDetailCoordinator.swift
//  CoronaContact
//

import UIKit

class DiaryDetailCoordinator: Coordinator {
    lazy var rootViewController: DiaryDetailViewController = {
        return  DiaryDetailViewController.instantiate()
    }()
    
    private var navigationController: UINavigationController
    private var diaryDayInfo: DiaryDayInfo
    
    init(navigationController: UINavigationController, diaryDayInfo: DiaryDayInfo) {
        self.navigationController = navigationController
        self.diaryDayInfo = diaryDayInfo
    }

    override func start() {
        rootViewController.viewModel = DiaryDetailViewModel(coordinator: self, diaryDayInfo: diaryDayInfo)
        navigationController.pushViewController(rootViewController, animated: true)
    }

    override func finish(animated: Bool = false) {
        if rootViewController.presentingViewController == navigationController {
            navigationController.dismiss(animated: animated) {
                self.parentCoordinator?.didFinish(self)
            }
        } else {
            parentCoordinator?.didFinish(self)
        }
    }
    
    func showAddNewEntryPopUp() {
        let child = DiaryAddEntryCoordinator(presentingViewController: rootViewController, selectedDate: diaryDayInfo.date)
        addChildCoordinator(child)
        child.start()
    }
    
    func showDelete(for baseDiaryInformation: BaseDiaryInformation) {
        let child = DiaryDeleteCoordinator(presentingViewController: rootViewController, baseDiaryInformation: baseDiaryInformation)
        addChildCoordinator(child)
        child.start()
    }
}
