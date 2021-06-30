//
//  DiaryEntry.swift
//  CoronaContact
//

import Foundation
import CoreData

enum DiaryEntry: CaseIterable {
    case person
    case location
    case publicTransport
    case event
    
    var translatedName: String {
        
        switch self {
        case .person:
            return "diary_add_person_pickerview".localized
        case .location:
            return "diary_add_location_pickerview".localized
        case .publicTransport:
            return "diary_add_public_transport_pickerview".localized
        case .event:
            return "diary_add_event_pickerview".localized
        }
    }
    
    var coreDataEntityName: String {
        switch self {
        case .person:
            return Person.entity().name ?? ""
        case .location:
            return Location.entity().name ?? ""
        case .publicTransport:
            return PublicTransport.entity().name ?? ""
        case .event:
            return Event.entity().name ?? ""
        }
    }
    
    var coreDataEncounterEntityName: String {
        switch self {
        case .person:
            return PersonEncounter.entity().name ?? ""
        case .location:
            return LocationEncounter.entity().name ?? ""
        case .publicTransport:
            return PublicTransportEncounter.entity().name ?? ""
        case .event:
            return EventEncounter.entity().name ?? ""
        }
    }
    
    var diaryEntryDetailIconName: String {
        switch self {
        case .person:
            return Person.entity().name ?? ""
        case .location:
            return Location.entity().name ?? ""
        case .publicTransport:
            return PublicTransport.entity().name ?? ""
        case .event:
            return Event.entity().name ?? ""
        }
    }
}
