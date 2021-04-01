//
//  EventEncounter+CoreDataProperties.swift
//  CoronaContact
//

import Foundation
import CoreData

extension EventEncounter {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EventEncounter> {
        return NSFetchRequest<EventEncounter>(entityName: "EventEncounter")
    }

    @NSManaged public var event: Event?

}
