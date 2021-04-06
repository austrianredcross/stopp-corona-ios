//
//  DiaryOverviewViewModel.swift
//  CoronaContact
//

import Resolver
import UIKit

class DiaryOverviewViewModel: ViewModel {
    
    @Injected private var coreDataService: CoreDataService
    
    weak var coordinator: DiaryOverviewCoordinator?
    
    private var diaryDayInfos: [DiaryDayInfo] = []
    var reloadTableView: (() -> Void)?

    init(coordinator: DiaryOverviewCoordinator) {
        self.coordinator = coordinator
    }
    
    var numberOfRows: Int {
        return diaryDayInfos.count
    }
    
    func viewWillAppear() {
        refresh()
    }
    
    func refresh() {
        
        diaryDayInfos.removeAll()
        
        let allEncounters = coreDataService.getAllEncounters()
                
        // getDates start to count from 0 
        for date in Date().getDates(forLastDays: 13) {
            
            let entriesForDate = allEncounters.filter({ $0.cdDate?.startOfDayUTC() == date.startOfDayUTC() }).map({ $0.getDiaryEntry() })
            
            let diaryDayInfo = DiaryDayInfo(date: date, diaryEntries: entriesForDate)
            diaryDayInfos.append(diaryDayInfo)
        }
        
        reloadTableView?()
    }
    
    func getCellTitle(index: Int) -> String {
        return diaryDayInfos[index].date.longDayMonthLongYear
    }
    
    func getEntryAmountString(index: Int) -> String? {
        let amount = diaryDayInfos[index].numberOfEntries
         
        let entryText = amount > 1 ? "diary_overview_cell_hint_2".localized : "diary_overview_cell_hint_1".localized
        return amount == 0 ? nil : "\(amount) " + entryText
    }
    
    func tableViewCellTapped(index: Int) {
        coordinator?.showDiaryDayDetailInfo(dayInfo: diaryDayInfos[index])
    }
    
    func showDiaryFaq() {
        coordinator?.showDiaryFaq()
    }
    
    func shareDiary() {
        coordinator?.shareDiary(diary: diaryDayInfos)
    }
}
