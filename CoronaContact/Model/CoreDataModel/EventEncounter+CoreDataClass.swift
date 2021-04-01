//
//  EventEncounter+CoreDataClass.swift
//  CoronaContact
//

import Foundation
import CoreData

@objc(EventEncounter)
public class EventEncounter: BaseEncounter {
    
    override func getDiaryEntry() -> BaseDiaryEntry? {
        return event
    }
}
