//
//  Bundesland+Localized.swift
//  CoronaContact
//

import Foundation

extension Bundesland {
    var localized: String {
        switch self {
        case .alle:
            return "covid_statistics_state_id_all".localized
        case .burgenland:
            return "covid_statistics_state_id_1".localized
        case .kärnten:
            return "covid_statistics_state_id_2".localized
        case .niederösterreich:
            return "covid_statistics_state_id_3".localized
        case .oberösterreich:
            return "covid_statistics_state_id_4".localized
        case .salzburg:
            return "covid_statistics_state_id_5".localized
        case .steiermark:
            return "covid_statistics_state_id_6".localized
        case .tirol:
            return "covid_statistics_state_id_7".localized
        case .vorarlberg:
            return "covid_statistics_state_id_8".localized
        case .wien:
            return "covid_statistics_state_id_9".localized
        case .österreich:
            return "covid_statistics_state_id_austria".localized
        }
    }
}
