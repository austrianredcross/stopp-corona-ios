//
//  BaseDiaryInformation.swift
//  CoronaContact
//

import Foundation

class BaseDiaryInformation {
    
    let diaryEntryType: DiaryEntry
    let encounterId: UUID
    let name: String
    var fullInfo: String { return "" }
    
    init(diaryEntryType: DiaryEntry, encounterId: UUID, name: String) {
        self.diaryEntryType = diaryEntryType
        self.encounterId = encounterId
        self.name = name
    }
}

class PersonDiaryEntryInformation: BaseDiaryInformation {
    
    var notice: String?
    
    override var fullInfo: String {
        var fullInfo = "\(name)"

        if let notice = notice, !notice.isEmpty {
            fullInfo += ", \(notice)"
        }

        return fullInfo
    }
    
    init(notice: String?, encounterId: UUID, name: String) {
        super.init(diaryEntryType: .person, encounterId: encounterId, name: name)
        self.notice = notice
    }
}

class LocationDiaryEntryInformation: BaseDiaryInformation {
    
    var dayPeriod: Int?
    
    override var fullInfo: String {
        var fullInfo = "\(name)"

        if let dayPeriodRawValue = dayPeriod, let dayPeriod = DayPeriod(rawValue: dayPeriodRawValue) {
            fullInfo += ", \(dayPeriod)"
        }

        return fullInfo
    }
    
    init(dayPeriod: NSNumber?, encounterId: UUID, name: String) {
        super.init(diaryEntryType: .location, encounterId: encounterId, name: name)
        
        guard let dayPeriodNumber = dayPeriod else { return }
        self.dayPeriod = Int(truncating: dayPeriodNumber)
    }
}

class PublicTransportDiaryEntryInformation: BaseDiaryInformation {
    
    var departureLocation: String?
    var destinationLocation: String?
    var departureTime: String?
    
    override var fullInfo: String {
        var fullInfo = "\(name)"

        if let departureTime = departureTime, !departureTime.isEmpty {
            fullInfo += ", \(departureTime)"
        }
        
        if let departureLocation = departureLocation, !departureLocation.isEmpty {
            fullInfo += ", \(departureLocation)"
        }
        
        if let destinationLocation = destinationLocation, !destinationLocation.isEmpty {
            fullInfo += " - \(destinationLocation)"
        }

        return fullInfo
    }
    
    init(departureLocation: String?, destinationLocation: String?, departureTime: String?, encounterId: UUID, name: String) {
        super.init(diaryEntryType: .publicTransport, encounterId: encounterId, name: name)
        self.departureLocation = departureLocation
        self.destinationLocation = destinationLocation
        self.departureTime = departureTime
    }
}

class EventDiaryEntryInformation: BaseDiaryInformation {
    
    var arrivalTime: String?
    var departureTime: String?

    override var fullInfo: String {
        var fullInfo = "\(name)"
        
        if let arrivalTime = arrivalTime, !arrivalTime.isEmpty {
            fullInfo += ", \(arrivalTime)"
        }
        
        if let departureTime = departureTime, !departureTime.isEmpty {
            fullInfo += ", \(departureTime)"
        }
        
        return fullInfo
    }
    
    init(arrivalTime: String?, departureTime: String?, encounterId: UUID, name: String) {
        super.init(diaryEntryType: .event, encounterId: encounterId, name: name)
        self.arrivalTime = arrivalTime
        self.departureTime = departureTime
    }
}
