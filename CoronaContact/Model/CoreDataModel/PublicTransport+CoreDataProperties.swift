//
//  PublicTransport+CoreDataProperties.swift
//  CoronaContact
//

import Foundation
import CoreData

extension PublicTransport {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PublicTransport> {
        return NSFetchRequest<PublicTransport>(entityName: "PublicTransport")
    }

    @NSManaged public var cdArrival: String?
    @NSManaged public var cdDeparture: String?
    @NSManaged public var cdTime: String?
    @NSManaged public var publicTransportEncounter: PublicTransportEncounter?
}
