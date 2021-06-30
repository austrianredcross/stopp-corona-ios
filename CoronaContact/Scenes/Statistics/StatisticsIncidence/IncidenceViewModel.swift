//
//  IncidenceViewModel.swift
//  CoronaContact
//

import Foundation
import Resolver

class Incidence: ViewModel {
    var incidenceState: IncidenceState
    var incidenceTitle: String
    
    var incidenceValueIcon: UIImage? {
        switch incidenceIncrementValue?.signPrefix {
        case .positive:
            return UIImage(named: "UpChange")
        case .negative:
            return UIImage(named: "DownChange")
        case .zero:
            return UIImage(named: "NoChange")
        default:
            return nil
        }
    }
    
    var incidenceValue: Double
    
    // The IncidenceIncrementValue can be nil because we have only have one day of Data from the Districts
    var incidenceIncrementValue: Double?
    
    var incidenceIncrementValueLocalized: String {
        switch incidenceIncrementValue?.signPrefix {
        case .positive:
            return "covid_statistics_increment_positive".localized
        case .negative:
            return "covid_statistics_increment_negative".localized
        case .zero:
            return "incidence_increment_value_no_changes".localized
        default:
            return ""
        }
    }
    
    init(incidenceState: IncidenceState, incidenceTitle: String, incidenceValue: Double, incidenceIncrementValue: Double?) {
        
        self.incidenceState = incidenceState
        self.incidenceTitle = incidenceTitle
        self.incidenceValue = incidenceValue
        self.incidenceIncrementValue = incidenceIncrementValue
    }
}

enum IncidenceState: CaseIterable {
    case zero
    case underOneHundred
    case aboveOneHundred
    case aboveTwoHundred
    case aboveFourHundred
    
    var color: UIColor {
        switch self {
        case .zero:
            return .ccIncidenceWhite
        case .underOneHundred:
            return .ccIncidenceYellow
        case .aboveOneHundred:
            return .ccIncidenceOrange
        case .aboveTwoHundred:
            return .ccIncidenceDarkRed
        case .aboveFourHundred:
            return .ccIncidenceBlack
        }
    }
    
    var localized: String {
        switch self {
        case .zero:
            return "covid_statistics_legend_no_changes".localized
        case .underOneHundred:
            return "covid_statistics_legend_under_one_hundred".localized
        case .aboveOneHundred:
            return "covid_statistics_legend_above_one_hundred".localized
        case .aboveTwoHundred:
            return "covid_statistics_legend_above_two_hundred".localized
        case .aboveFourHundred:
            return "covid_statistics_legend_above_four_hundred".localized
        }
    }
    
    var accessibilityLocalized: String {
        
        var texts = ["accessibility_incidence_level".localized]

        switch self {
        case .zero:
            texts.append("accessibility_covid_statistics_legend_no_changes".localized)
        case .underOneHundred:
            texts.append("accessibility_covid_statistics_legend_under_one_hundred".localized)
        case .aboveOneHundred:
            texts.append("accessibility_covid_statistics_legend_above_one_hundred".localized)
        case .aboveTwoHundred:
            texts.append("accessibility_covid_statistics_legend_above_two_hundred".localized)
        case .aboveFourHundred:
            texts.append("accessibility_covid_statistics_legend_above_four_hundred".localized)
        }
        
        return texts.joined(separator: ",")
    }
    
    init(_ incidences: Double) {
        switch incidences {
        case 0:
            self = .zero
        case 1..<100:
            self = .underOneHundred
        case 100..<200:
            self = .aboveOneHundred
        case 200..<400:
            self = .aboveTwoHundred
        default:
            self = .aboveFourHundred
        }
    }
}
