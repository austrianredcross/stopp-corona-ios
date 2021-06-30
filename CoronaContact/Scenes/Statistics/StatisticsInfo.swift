//
//  StatisticsInfo.swift
//  CoronaContact
//

import UIKit

class StatisticsDetails {
    let title: String
    let currentValue: Double
    let delta: Double
    
    init(title: String, currentValue: Double, delta: Double) {
        self.title = title
        self.currentValue = currentValue
        self.delta = delta
    }
}

class StatisticsInfo {
    
    let topInfo: StatisticsDetails
    let bottomInfo: StatisticsDetails
    let showPrefixImage: Bool
    
    init(topInfo: StatisticsDetails, bottomInfo: StatisticsDetails, showPrefixImage: Bool) {
        
        self.topInfo = topInfo
        self.bottomInfo = bottomInfo
        self.showPrefixImage = showPrefixImage
    }
    
    func loadSignPrefixImage(from value: Double) -> UIImage? {
        
        guard showPrefixImage else { return nil }
        switch value.signPrefix {
        case .positive:
            return UIImage(named: "UpChange")
        case .negative:
            return UIImage(named: "DownChange")
        case .zero:
            return UIImage(named: "NoChange")
        }
    }
    
    func loadSignPrefixText(from value: Double) -> String {
        guard showPrefixImage else { return "" }

        switch value.signPrefix {
        case .positive:
            return "covid_statistics_increment_positive".localized
        case .negative:
            return "covid_statistics_increment_negative".localized
        case .zero:
            return "incidence_increment_value_no_changes".localized
        }
    }
}
