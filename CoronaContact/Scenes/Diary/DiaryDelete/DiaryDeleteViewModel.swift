//
//  DiaryDeleteViewModel.swift
//  CoronaContact
//

import Resolver
import UIKit
import CoreData

class DiaryDeleteViewModel: ViewModel {
        
    weak var coordinator: DiaryDeleteCoordinator?

    let baseDiaryInformation: BaseDiaryInformation
    
    init(coordinator: DiaryDeleteCoordinator, baseDiaryInformation: BaseDiaryInformation) {
        self.coordinator = coordinator
        self.baseDiaryInformation = baseDiaryInformation
    }
    
    func deletePressed() {
        coordinator?.deletePressed()
    }
    
    func cancelPressed() {
        coordinator?.finish()
    }
}
