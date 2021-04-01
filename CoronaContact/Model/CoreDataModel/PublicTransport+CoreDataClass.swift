//
//  PublicTransport+CoreDataClass.swift
//  CoronaContact
//

import Foundation
import CoreData

@objc(PublicTransport)
public class PublicTransport: BaseDiaryEntry {
    
    override var diaryInformation: BaseDiaryInformation? {
        return PublicTransportDiaryEntryInformation(departureLocation: cdDeparture,
                                                    destinationLocation: cdArrival,
                                                    departureTime: cdTime,
                                                    encounterId: publicTransportEncounter?.cdId ?? UUID(),
                                                    name: cdName ?? "")
    }
}
