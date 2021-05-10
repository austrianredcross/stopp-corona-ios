//
//  DiaryDetailEntryCellViewModel.swift
//  CoronaContact
//

import Foundation
import Resolver

class DiaryDetailEntryCellViewModel: ViewModel {

    @Injected private var coreDataService: CoreDataService
    
    private var diaryDetailViewModel: DiaryDetailViewModel
    private var diaryEntryInformation: BaseDiaryInformation
    
    var diaryEntryIconImage: UIImage? {
        let image = UIImage(named: diaryEntryInformation.diaryEntryType.diaryEntryDetailIconName)
        image?.accessibilityLabel = diaryEntryInformation.diaryEntryType.diaryEntryDetailIconName
        
        return image
    }
    
    var diaryEntryTitle: String {
        return diaryEntryInformation.name
    }
    
    var diaryEntryInformationLabels: [UILabel] {
        
        switch diaryEntryInformation.diaryEntryType {
        case .person:
            guard let entryInformation = diaryEntryInformation as? PersonDiaryEntryInformation else { return [] }
            return configurePersonEntryInformation(entryInformation: entryInformation)
        case .location:
            guard let entryInformation = diaryEntryInformation as? LocationDiaryEntryInformation else { return [] }
            return configureLocationEntryInformation(entryInformation: entryInformation)
        case .event:
            guard let entryInformation = diaryEntryInformation as? EventDiaryEntryInformation else { return [] }
            return configureEventEntryInformation(entryInformation: entryInformation)
        case .publicTransport:
            guard let entryInformation = diaryEntryInformation as? PublicTransportDiaryEntryInformation else { return [] }
            return configurePublicTransportEntryInformation(entryInformation: entryInformation)
        }
    }
    
    init(diaryDetailViewModel: DiaryDetailViewModel, diaryEntryInformation: BaseDiaryInformation) {
        self.diaryDetailViewModel = diaryDetailViewModel
        self.diaryEntryInformation = diaryEntryInformation
    }
    
    func deleteEntryButtonPressed() {
        diaryDetailViewModel.showDelete(for: diaryEntryInformation)
    }
    
    private func configurePersonEntryInformation(entryInformation: PersonDiaryEntryInformation) -> [UILabel] {
        
        var labels: [UILabel] = []
        
        if let text = entryInformation.notice, !text.isEmpty {
            let noticeLabel = UILabel()
            noticeLabel.text = entryInformation.notice
            labels.append(noticeLabel)
        }
        
        return labels
    }
    
    private func configureLocationEntryInformation(entryInformation: LocationDiaryEntryInformation) -> [UILabel] {
        
        var labels: [UILabel] = []
        
        if entryInformation.dayPeriod != nil {
            if let dayPeriodEnum = DayPeriod(rawValue: entryInformation.dayPeriod!) {
                let dayPeriodLabel = UILabel()
                dayPeriodLabel.text = dayPeriodEnum.translated
                labels.append(dayPeriodLabel)
            }
        }
        
        return labels
    }
    
    private func configurePublicTransportEntryInformation(entryInformation: PublicTransportDiaryEntryInformation) -> [UILabel] {
        var labels: [UILabel] = []
        
        var locationInfo = ""
        if let departureLocation = entryInformation.departureLocation, !departureLocation.isEmpty {
            locationInfo = "\(departureLocation)"
        }
        
        if let destinationLocation = entryInformation.destinationLocation, !destinationLocation.isEmpty {
            locationInfo = locationInfo.isEmpty ? "\(destinationLocation)" : "\(locationInfo) - \(destinationLocation)"
        }
            
        if !locationInfo.isEmpty {
            let label = UILabel()
            label.text = locationInfo
            labels.append(label)
        }
        
        if let departureTime = entryInformation.departureTime, !departureTime.isEmpty {
            let label = UILabel()
            label.text = departureTime
            labels.append(label)
        }
        
        return labels
    }
    
    private func configureEventEntryInformation(entryInformation: EventDiaryEntryInformation) -> [UILabel] {
        var labels: [UILabel] = []
        
        var fullInfo = ""
        if let arrivalTime = entryInformation.arrivalTime, !arrivalTime.isEmpty {
            fullInfo = "\(arrivalTime)"
        }
        
        if let departureTime = entryInformation.departureTime, !departureTime.isEmpty {
            fullInfo = fullInfo.isEmpty ? "\(departureTime)" : "\(fullInfo) - \(departureTime)"
        }
    
        if !fullInfo.isEmpty {
            let location = UILabel()
            location.text = fullInfo
            labels.append(location)
        }
                
        return labels
    }
}
