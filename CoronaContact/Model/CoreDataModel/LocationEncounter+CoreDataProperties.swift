//
//  LocationEncounter+CoreDataProperties.swift
//  CoronaContact
//

import Foundation
import CoreData

extension LocationEncounter {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<LocationEncounter> {
        return NSFetchRequest<LocationEncounter>(entityName: "LocationEncounter")
    }

    @NSManaged public var location: Location?
}
