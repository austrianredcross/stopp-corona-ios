//
//  SelfTestingCoronaSuspicionViewModel.swift
//  CoronaContact
//

import Foundation
import Resolver

class SelfTestingCoronaSuspicionViewModel: ViewModel {
    @Injected private var localStorage: LocalStorage
    
    weak var coordinator: SelfTestingCoronaSuspicionCoordinator?
    
    init(with coordinator: SelfTestingCoronaSuspicionCoordinator) {
        self.coordinator = coordinator
    }
    
    func showRevocation() {
        
        guard let coordinator = coordinator else { return }
        let child = SicknessCertificateCoordinator(navigationController: coordinator.navigationController)
        
        coordinator.addChildCoordinator(child)
        child.start()
    }
    
    func showStatusReport() {
        
        guard let coordinator = coordinator else { return }
        
        let child = SelfTestingSuspicionCoordinator(navigationController: coordinator.navigationController)
        coordinator.addChildCoordinator(child)
        child.start()
    }
    
    func saveSelectedReportDate(reportDate: Date) {
        localStorage.hasSymptomsOrPositiveAttestAt = reportDate
    }
    
    func viewClosed() {
        localStorage.hasSymptomsOrPositiveAttestAt = nil
    }
}
