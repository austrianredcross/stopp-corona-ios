//
//  DiaryDetailViewModel.swift
//  CoronaContact
//

import Resolver
import UIKit
import CoreData

class DiaryDetailViewModel: ViewModel {
    
    @Injected private var coreDataService: coreDataService
    
    private var diaryDayInfo: DiaryDayInfo
    private var coordinator: DiaryDetailCoordinator
    
    var reloadTableView: (() -> Void)?
    
    var title: String {
        return diaryDayInfo.date.longDayMonthLongYear
    }
    
    var numberOfRows: Int {
        return diaryDayInfo.numberOfEntries
    }
        
    init(coordinator: DiaryDetailCoordinator, diaryDayInfo: DiaryDayInfo) {
        self.coordinator = coordinator
        self.diaryDayInfo = diaryDayInfo
    }
    
    func refreshData() {
        let diaryEntries = coreDataService.getAllEncounters().filter({ $0.cdDate == diaryDayInfo.date }).compactMap({ $0.getDiaryEntry() })
        
        diaryDayInfo = DiaryDayInfo(date: diaryDayInfo.date, diaryEntries: diaryEntries)
        reloadTableView?()
    }
    
    func getDiaryEntryInformation(for index: Int) -> BaseDiaryInformation? {
        return diaryDayInfo.diaryEntries[index]?.diaryInformation
    }
    
    func addNewEntryButtonPressed() {
        coordinator.showAddNewEntryPopUp()
    }
    
    func showDelete(for baseDiaryInformation: BaseDiaryInformation) {
        coordinator.showDelete(for: baseDiaryInformation)
    }
}
