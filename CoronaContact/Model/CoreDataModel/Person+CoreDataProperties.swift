//
//  Person+CoreDataProperties.swift
//  CoronaContact
//

import Foundation
import CoreData


extension Person {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Person> {
        return NSFetchRequest<Person>(entityName: "Person")
    }

    @NSManaged public var cdNotice: String?
    @NSManaged public var personEncounter: PersonEncounter?
}
