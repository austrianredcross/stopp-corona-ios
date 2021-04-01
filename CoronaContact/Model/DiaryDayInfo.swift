//
//  DiaryDayInfo.swift
//  CoronaContact
//

import Foundation
import CoreData

class DiaryDayInfo {
    
    let date: Date
    let diaryEntries: [BaseDiaryEntry?]
    
    var numberOfEntries: Int {
        return diaryEntries.count
    }
    
    init(date: Date, diaryEntries: [BaseDiaryEntry?]) {
        self.date = date
        self.diaryEntries = diaryEntries
    }
}
