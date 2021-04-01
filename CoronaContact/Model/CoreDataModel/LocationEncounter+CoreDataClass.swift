//
//  LocationEncounter+CoreDataClass.swift
//  CoronaContact
//

import Foundation
import CoreData

@objc(LocationEncounter)
public class LocationEncounter: BaseEncounter {
    
    override func getDiaryEntry() -> BaseDiaryEntry? {
        return location
    }
}
