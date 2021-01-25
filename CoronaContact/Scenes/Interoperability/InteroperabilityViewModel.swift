//
//  InteroperabilityViewModel.swift
//  CoronaContact
//

import Foundation
import Resolver


final class InteroperabilityViewModel: ViewModel {
    
    @Injected private var localStorage: LocalStorage
    
    weak var coordinator: InteroperabilityCoordinator?
    
    init(coordinator: InteroperabilityCoordinator) {
        self.coordinator = coordinator
    }
    
    func agreedButtonPressed() {
        localStorage.hasBeenAgreedInteroperability = true
        self.coordinator?.finish()
    }
}
