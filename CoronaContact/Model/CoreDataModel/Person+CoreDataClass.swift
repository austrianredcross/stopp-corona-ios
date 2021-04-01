//
//  Person+CoreDataClass.swift
//  CoronaContact
//

import Foundation
import CoreData

@objc(Person)
public class Person: BaseDiaryEntry {
    
    override var diaryInformation: BaseDiaryInformation? {
        return PersonDiaryEntryInformation(notice: cdNotice, encounterId: personEncounter?.cdId ?? UUID(), name: cdName ?? "")
    }
}
