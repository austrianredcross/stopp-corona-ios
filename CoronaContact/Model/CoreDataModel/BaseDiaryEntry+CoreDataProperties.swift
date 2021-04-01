//
//  BaseDiaryEntry+CoreDataProperties.swift
//  CoronaContact
//

import Foundation
import CoreData

extension BaseDiaryEntry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BaseDiaryEntry> {
        return NSFetchRequest<BaseDiaryEntry>(entityName: "BaseDiaryEntry")
    }

    @NSManaged public var cdName: String?
}

extension BaseDiaryEntry : Identifiable {

}
