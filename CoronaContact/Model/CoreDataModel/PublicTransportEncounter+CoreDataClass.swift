//
//  PublicTransportEncounter+CoreDataClass.swift
//  CoronaContact
//

import Foundation
import CoreData

@objc(PublicTransportEncounter)
public class PublicTransportEncounter: BaseEncounter {
    
    override func getDiaryEntry() -> BaseDiaryEntry? {
        return publicTransport
    }
}
