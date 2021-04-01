//
//  BaseEncounter+CoreDataClass.swift
//  CoronaContact
//

import Foundation
import CoreData

@objc(BaseEncounter)
public class BaseEncounter: NSManagedObject {
    
    func getDiaryEntry() -> BaseDiaryEntry? { return nil }
}
