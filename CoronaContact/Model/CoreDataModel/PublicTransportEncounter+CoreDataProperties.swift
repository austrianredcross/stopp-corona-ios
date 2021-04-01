//
//  PublicTransportEncounter+CoreDataProperties.swift
//  CoronaContact
//

import Foundation
import CoreData

extension PublicTransportEncounter {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PublicTransportEncounter> {
        return NSFetchRequest<PublicTransportEncounter>(entityName: "PublicTransportEncounter")
    }

    @NSManaged public var publicTransport: PublicTransport?
}
