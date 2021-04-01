//
//  Event+CoreDataClass.swift
//  CoronaContact
//

import Foundation
import CoreData

@objc(Event)
public class Event: BaseDiaryEntry {

    override var diaryInformation: BaseDiaryInformation? {
        return EventDiaryEntryInformation(arrivalTime: cdArrivalTime, departureTime: cdDepartureTime, encounterId: eventEncounter?.cdId ?? UUID(), name: cdName ?? "")
    }
}
