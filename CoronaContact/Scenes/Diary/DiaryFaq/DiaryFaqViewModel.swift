//
//  DiaryFaqViewModel.swift
//  CoronaContact
//

import Resolver
import UIKit

class DiaryFaqViewModel: ViewModel {
        
    weak var coordinator: DiaryFaqCoordinator?

    init(coordinator: DiaryFaqCoordinator) {
        self.coordinator = coordinator
    }
}
