//
//  StatisticsLegendViewModel.swift
//  CoronaContact
//
import Foundation
import Resolver

class StatisticsLegendViewModel: ViewModel {
    weak var coordinator: StatisticsLegendCoordinator?

    init(with coordinator: StatisticsLegendCoordinator) {
        self.coordinator = coordinator
    }
    
    func closeLegend() {
        coordinator?.dismiss()
    }
}
