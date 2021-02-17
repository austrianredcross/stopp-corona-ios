//
//  ReportHealthyViewModel.swift
//  CoronaContact
//

import Foundation
import Resolver

class ReportHealthyViewModel: ViewModel {
    
    @Injected private var localStorage: LocalStorage
    weak var coordinator: ReportHealthyCoordinator?
    
    func quitQuarantineButtonPressed() {
        localStorage.finishProvenSicknessQuarantine = true
        localStorage.attestedSicknessAt = nil
        localStorage.missingUploadedKeysAt = nil
        coordinator?.dismiss()
    }
    
    func cancelButtonPressed() {
        coordinator?.dismiss()
    }
}
