//
//  BaseEncounter+CoreDataProperties.swift
//  CoronaContact
//

import Foundation
import CoreData

extension BaseEncounter {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BaseEncounter> {
        return NSFetchRequest<BaseEncounter>(entityName: "BaseEncounter")
    }

    @NSManaged public var cdId: UUID?
    @NSManaged public var cdDate: Date?
}

extension BaseEncounter : Identifiable {

}
