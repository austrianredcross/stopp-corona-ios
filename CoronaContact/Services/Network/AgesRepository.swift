//
//  AGESRepository.swift
//  CoronaContact
//
import Foundation
import Resolver

extension Resolver {
    public static func registerAGESRepository() {
        register { () -> AGESRepository in
            return AGESRepository()
        }.scope(application)
    }
}

class AGESRepository {
    @Injected private var networkService: NetworkService
    @Injected private var localStorage: LocalStorage

    @Observable var covidStatistics: CovidStatistics?

    var subscriptions = Set<AnySubscription>()
    var updateView: (() -> Void)?
    var showError: ((Error) -> Void)?
    
    // Can be nil if the Dates we get from AGES are invalid
    var lastDate: Date?
    var penultimateDate: Date?
    var isDataLoading = false
    
    init() {
        $covidStatistics.subscribe { [weak self] _ in
            guard let self = self else { return }
            self.updateView?()
        }.add(to: &subscriptions)
        
        fetchStatistics()
    }
    
    func fetchStatistics() {
        isDataLoading = true
        
        networkService.downloadCovidStatistics { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(response):
                self.isDataLoading = false

                self.setDatesForComparison(with: response)
                self.localStorage.latestAGESDownload = self.covidStatistics?.creationDate

            case .failure(let error):
                self.isDataLoading = false

                self.showError?(error)
            }
        }
    }
    
    func setDatesForComparison(with covidStatistics: CovidStatistics) {
        guard let lastTwoElements = covidStatistics.covidFaelleTimeline.filter({ $0.bundesland == .österreich }).lastTwoElements() else {
            self.showError?(AGESError.invalidValidation)
            return
        }
        
        do {
            self.lastDate = try lastTwoElements.lastDay.agesDateString.convertToDate()
            self.penultimateDate = try lastTwoElements.penultimateDay.agesDateString.convertToDate()
            
            self.covidStatistics = covidStatistics
        } catch {
            self.showError?(error)
        }
    }
    
    func drawImage(from state: Bundesland) throws -> UIImage? {
        guard let statistics = covidStatistics else { return nil }

        return try StateDrawer.shared.drawImage(from: state, with: statistics)
    }
}
