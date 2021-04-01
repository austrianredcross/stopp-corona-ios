//
//  Location+CoreDataClass.swift
//  CoronaContact
//

import Foundation
import CoreData

@objc(Location)
public class Location: BaseDiaryEntry {
    
    override var diaryInformation: BaseDiaryInformation? {
        return LocationDiaryEntryInformation(dayPeriod: cdDayPeriod, encounterId: locationEncounter?.cdId ?? UUID(), name: cdName ?? "")
    }
}
