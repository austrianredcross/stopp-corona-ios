//
//  DiaryAddEntryViewModel.swift
//  CoronaContact
//

import Foundation
import Resolver

class DiaryAddEntryViewModel: ViewModel {
    
    @Injected private var coreDataService: coreDataService
    
    private var coordinator: DiaryAddEntryCoordinator
    private var viewController: DiaryAddEntryViewController
    private var saveEntityDate: Date
    
    var currentSelectedDiaryEntry: DiaryEntry = .person
    
    init(coordinator: DiaryAddEntryCoordinator, viewController: DiaryAddEntryViewController, saveEntityDate: Date) {
        self.coordinator = coordinator
        self.viewController = viewController
        self.saveEntityDate = saveEntityDate
    }
    
    func closeButtonPressed() {
        coordinator.dismiss()
    }
    
    func saveButtonPressed() {
        
        switch currentSelectedDiaryEntry {
        case .person:
            savePersonIntoCoreData()
        case .location:
            saveLocationIntoCoreData()
        case .publicTransport:
            savePublicTransportIntoCoreData()
        case .event:
            saveEventIntoCoreData()
        }
    }
    
    private func savePersonIntoCoreData() {
        
        guard let context = coreDataService.context else { return }
        
        guard let personName = viewController.nonOptionalTextField.text, !personName.isEmpty else { return }
        
        let newPerson = Person(context: context)
        newPerson.cdName = personName
        newPerson.cdNotice = viewController.personNoticeTextView.textColor != UIColor.lightGray ? viewController.personNoticeTextView.text : ""
        
        let newPersonEncounter = PersonEncounter(context: context)
        newPersonEncounter.person = newPerson
        newPersonEncounter.cdId = UUID()
        newPersonEncounter.cdDate = saveEntityDate
        
        coreDataService.save { [weak self] in
            self?.coordinator.dismiss()
        }
    }
    
    private func saveLocationIntoCoreData() {
        
        guard let context = coreDataService.context else { return }
        
        guard let locationName = viewController.nonOptionalTextField.text, !locationName.isEmpty else { return }
        let dayPeriodSelection = viewController.locationDayPeriodSelectorView.selectedDayPeriod
        
        let newLocation = Location(context: context)
        newLocation.cdName = locationName
        newLocation.cdDayPeriod = dayPeriodSelection?.rawValue as NSNumber?
        
        let newLocationEncounter = LocationEncounter(context: context)
        newLocationEncounter.location = newLocation
        newLocationEncounter.cdId = UUID()
        newLocationEncounter.cdDate = saveEntityDate
        
        coreDataService.save { [weak self] in
            self?.coordinator.dismiss()
        }
    }
    
    private func savePublicTransportIntoCoreData() {
        
        guard let context = coreDataService.context else { return }
        
        guard let publicTransportName = viewController.nonOptionalTextField.text, !publicTransportName.isEmpty else { return }
        let departureName = viewController.publicTransportDepartureTextField.text
        let destinationName = viewController.publicTransportDestinationTextField.text
        let departureTime = viewController.publicTransportDepartureTimeTextField.text
        
        let newPublicTransport = PublicTransport(context: context)
        newPublicTransport.cdName = publicTransportName
        newPublicTransport.cdDeparture = departureName
        newPublicTransport.cdArrival = destinationName
        newPublicTransport.cdTime = departureTime
        
        let newPublicTransportEncounter = PublicTransportEncounter(context: context)
        newPublicTransportEncounter.publicTransport = newPublicTransport
        newPublicTransportEncounter.cdId = UUID()
        newPublicTransportEncounter.cdDate = saveEntityDate
        
        coreDataService.save { [weak self] in
            self?.coordinator.dismiss()
        }
    }
    
    private func saveEventIntoCoreData() {
        
        guard let context = coreDataService.context else { return }
        
        guard let eventName = viewController.nonOptionalTextField.text, !eventName.isEmpty else { return }

        let arrivalTime = viewController.eventArrivalTimeTextField.text
        let departureTime = viewController.eventDepartureTimeTextField.text
        
        let newEvent = Event(context: context)
        newEvent.cdArrivalTime = arrivalTime
        newEvent.cdDepartureTime = departureTime
        newEvent.cdName = eventName
        
        let newEventEncounter = EventEncounter(context: context)
        newEventEncounter.event = newEvent
        newEventEncounter.cdId = UUID()
        newEventEncounter.cdDate = saveEntityDate
        
        coreDataService.save { [weak self] in
            self?.coordinator.dismiss()
        }
    }
}
