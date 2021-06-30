//
//  StatisticsDetailViewModel.swift
//  CoronaContact
//

import Foundation
import Resolver

class StatisticsDetailViewModel: ViewModel {
    @Injected var agesRepository: AGESRepository

    weak var coordinator: StatisticsDetailCoordinator?    
    
    var pageCount: Int {
        return statisticsInfo.count
    }
    
    var statisticsInfo: [StatisticsInfo] = []
    var incidences: [Incidence] = []
    var updateView: (() -> Void)?
    var selectedState: Bundesland = .österreich

    private let bundesland: [Bundesland] = Bundesland.getCases
    // Creates a dictionary with one key per state. Every value is initialized as an empty array.
    private var stateIncidencesDict: [Bundesland: [Incidence]] = Dictionary(uniqueKeysWithValues: Bundesland.getCases.map { ($0, []) })
    private var statisticsInfoDict: [Bundesland: [StatisticsInfo]] = Dictionary(uniqueKeysWithValues: Bundesland.getCases.map { ($0, []) })

    init(with coordinator: StatisticsDetailCoordinator) {
        self.coordinator = coordinator
    }
    
    func showLegend() {
        coordinator?.showLegend()
    }
    
    func loadData() {
        setupIncidences()
        setupStatisticsInfo()
    }
    
    func selectedState(state: Bundesland) {
        selectedState = state
        reloadIncidences()
        reloadStatisticsInfo()
        updateView?()
    }

    func drawMap() -> UIImage? {
        do {
            return try agesRepository.drawImage(from: selectedState)
        } catch {
            coordinator?.showErrorAlert(with: error)
            return nil
        }
    }
    
    func reloadIncidences() {
        guard let selectedIndicesForState = stateIncidencesDict[selectedState] else { return }
        incidences = selectedIndicesForState
    }
    
    func reloadStatisticsInfo() {
        guard let statisticsInfoForState = statisticsInfoDict[selectedState] else { return }
        statisticsInfo = statisticsInfoForState
    }
    
    func setupIncidences() {
        do {
            
            try Bundesland.getCases.forEach({ state in
                try agesRepository.covidStatistics?.covidFaelleGKZ.filter({ try $0.getState() == state }).forEach({ oneGKZ in
                    stateIncidencesDict[state]?.append(Incidence(incidenceState: IncidenceState(oneGKZ.incidenceValue), incidenceTitle: oneGKZ.bezirk, incidenceValue: oneGKZ.incidenceValue, incidenceIncrementValue: nil))
                })
                
                guard let covidFaelleTimelineFiltered = agesRepository.covidStatistics?.covidFaelleTimeline.filter({ $0.bundesland == state }) else { return }
                
                let lastTwoTimeLines = covidFaelleTimelineFiltered.lastTwoElements()
                
                guard let lastDayCovidFaelleTimeline = lastTwoTimeLines?.lastDay as? CovidFaelleTimeline,
                      let penultimateDayCovidFaelleTimeline = lastTwoTimeLines?.penultimateDay as? CovidFaelleTimeline else { return }
                
                let siebenTageInzidenzFaelleDiff = lastDayCovidFaelleTimeline.siebenTageInzidenzFaelle - penultimateDayCovidFaelleTimeline.siebenTageInzidenzFaelle
                
                stateIncidencesDict[.österreich]?.append(Incidence(incidenceState: IncidenceState(lastDayCovidFaelleTimeline.siebenTageInzidenzFaelle), incidenceTitle: state.localized, incidenceValue: lastDayCovidFaelleTimeline.siebenTageInzidenzFaelle, incidenceIncrementValue: siebenTageInzidenzFaelleDiff))
            })
        } catch {
            coordinator?.showErrorAlert(with: error)
        }
    }
    
    func setupStatisticsInfo() {
  
        for oneState in bundesland {
            let lastTwoTimeLines = agesRepository.covidStatistics?.covidFaelleTimeline.filter({ $0.bundesland == oneState }).lastTwoElements()
            
            // This looks weird but there is no covidFallzahlen for the state .österreich
            let lastTwoCovidFallZahlen = agesRepository.covidStatistics?.covidFallzahlen.filter({ $0.bundesland == (oneState == .österreich ? .alle : oneState) }).lastTwoElements()
        
            guard let lastDayCovidFaelleTimeline = lastTwoTimeLines?.lastDay as? CovidFaelleTimeline,
                  let penultimateDayCovidFaelleTimeline = lastTwoTimeLines?.penultimateDay as? CovidFaelleTimeline,
                  let lastDayCovidFallZahlen = lastTwoCovidFallZahlen?.lastDay as? CovidFallzahlen,
                  let penultimateDayCovidFallZahlen = lastTwoCovidFallZahlen?.penultimateDay as? CovidFallzahlen else { return }
            
            var tmpStatistics = [StatisticsInfo]()
            
            // MARK: - Load Confirmed Cases and Seven days Incidences
            
            let anzahlFaelleDiff = lastDayCovidFaelleTimeline.anzahlFaelle - penultimateDayCovidFaelleTimeline.anzahlFaelle
            let siebenTageInzidenzFaelleDiff = lastDayCovidFaelleTimeline.siebenTageInzidenzFaelle - penultimateDayCovidFaelleTimeline.siebenTageInzidenzFaelle
            
            tmpStatistics.append(StatisticsInfo(topInfo:
                                                StatisticsDetails(title: "covid_statistics_confirmed_cases".localized, currentValue: lastDayCovidFaelleTimeline.anzahlFaelle.asDouble, delta: anzahlFaelleDiff.asDouble), bottomInfo:
                                                StatisticsDetails(title: "covid_statistics_seven_day_incidence".localized, currentValue: lastDayCovidFaelleTimeline.siebenTageInzidenzFaelle, delta: siebenTageInzidenzFaelleDiff),
                                                showPrefixImage: true))
            
            // MARK: - Load current hospitalized and current intensive
            
            let fzHospDiff = lastDayCovidFallZahlen.fzHosp - penultimateDayCovidFallZahlen.fzHosp
            let fzicuDiff = lastDayCovidFallZahlen.fzicu - penultimateDayCovidFallZahlen.fzicu
            
            tmpStatistics.append(StatisticsInfo(topInfo:
                                                StatisticsDetails(title: "covid_statistics_current_hospitalized".localized, currentValue: lastDayCovidFallZahlen.fzHosp.asDouble, delta: fzHospDiff.asDouble), bottomInfo:
                                                StatisticsDetails(title: "covid_statistics_current_intensive".localized, currentValue: lastDayCovidFallZahlen.fzicu.asDouble, delta: fzicuDiff.asDouble),
                                                showPrefixImage: true))
            
            // MARK: - Load confirmed laboratory and accomplished tests
            
            let testGesamtDiff = lastDayCovidFallZahlen.testGesamt - penultimateDayCovidFallZahlen.testGesamt
            let confirmedLaboratoryDiff = lastDayCovidFaelleTimeline.anzahlFaelleSum - penultimateDayCovidFaelleTimeline.anzahlFaelleSum
            
            tmpStatistics.append(StatisticsInfo(topInfo:
                                                StatisticsDetails(title: "covid_statistics_confirmed_laboratory".localized, currentValue: lastDayCovidFaelleTimeline.anzahlFaelleSum.asDouble, delta: confirmedLaboratoryDiff.asDouble), bottomInfo:
                                                StatisticsDetails(title: "covid_statistics_accomplished_tests".localized, currentValue: lastDayCovidFallZahlen.testGesamt.asDouble, delta: testGesamtDiff.asDouble),
                                                showPrefixImage: false))
            
            // MARK: - Load healed cases and all death cases
            
            let anzahlGeheiltSumDiff = lastDayCovidFaelleTimeline.anzahlGeheiltSum - penultimateDayCovidFaelleTimeline.anzahlGeheiltSum
            let anzahlTotSumDiff = lastDayCovidFaelleTimeline.anzahlTotSum - penultimateDayCovidFaelleTimeline.anzahlTotSum
            
            tmpStatistics.append(StatisticsInfo(topInfo:
                                                StatisticsDetails(title: "covid_statistics_healed_cases".localized, currentValue: lastDayCovidFaelleTimeline.anzahlGeheiltSum.asDouble, delta: anzahlGeheiltSumDiff.asDouble), bottomInfo:
                                                StatisticsDetails(title: "covid_statistics_death_cases".localized, currentValue: lastDayCovidFaelleTimeline.anzahlTotSum.asDouble, delta: anzahlTotSumDiff.asDouble),
                                                showPrefixImage: false))
            
            statisticsInfoDict[oneState] = tmpStatistics
        }
    }
}
