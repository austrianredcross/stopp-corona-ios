//
//  PersonEncounter+CoreDataClass.swift
//  CoronaContact
//

import Foundation
import CoreData

@objc(PersonEncounter)
public class PersonEncounter: BaseEncounter {
    
    override func getDiaryEntry() -> BaseDiaryEntry? {
        return person
    }
}
