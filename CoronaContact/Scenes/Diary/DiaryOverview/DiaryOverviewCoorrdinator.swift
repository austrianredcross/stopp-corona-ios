//
//  DiaryOverviewCoorrdinator.swift
//  CoronaContact
//

import UIKit

class DiaryOverviewCoordinator: Coordinator, ShareSheetPresentable {
    var navigationController: UINavigationController

    lazy var rootViewController: DiaryOverviewViewController = {
        return DiaryOverviewViewController.instantiate(with: DiaryOverviewViewModel(coordinator: self))
    }()

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    override func start() {
        navigationController.pushViewController(rootViewController, animated: true)
    }
    
    func showDiaryDayDetailInfo(dayInfo: DiaryDayInfo) {
        let child = DiaryDetailCoordinator(navigationController: navigationController, diaryDayInfo: dayInfo)
        addChildCoordinator(child)
        child.start()
    }
    
    func showDiaryFaq() {
        let child = DiaryFaqCoordinator(navigationController: navigationController)
        addChildCoordinator(child)
        child.start()
    }
    
    func shareDiary(diary: [DiaryDayInfo]) {
        presentShareDiary(diary: diary)
    }

    override func finish(animated: Bool = false) {
        parentCoordinator?.didFinish(self)
    }
}
