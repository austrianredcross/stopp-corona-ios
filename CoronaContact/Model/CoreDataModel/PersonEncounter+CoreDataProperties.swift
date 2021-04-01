//
//  PersonEncounter+CoreDataProperties.swift
//  CoronaContact
//

import Foundation
import CoreData

extension PersonEncounter {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PersonEncounter> {
        return NSFetchRequest<PersonEncounter>(entityName: "PersonEncounter")
    }

    @NSManaged public var person: Person?
}
