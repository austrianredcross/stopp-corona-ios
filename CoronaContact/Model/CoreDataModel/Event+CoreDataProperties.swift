//
//  Event+CoreDataProperties.swift
//  CoronaContact
//

import Foundation
import CoreData

extension Event {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Event> {
        return NSFetchRequest<Event>(entityName: "Event")
    }

    @NSManaged public var cdArrivalTime: String?
    @NSManaged public var cdDepartureTime: String?
    @NSManaged public var eventEncounter: EventEncounter?

}
