//
//  Location+CoreDataProperties.swift
//  CoronaContact
//

import Foundation
import CoreData

extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }

    @NSManaged public var cdDayPeriod: NSNumber?
    @NSManaged public var locationEncounter: LocationEncounter?
}
