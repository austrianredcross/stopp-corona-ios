//
//  AGESDate.swift
//  CoronaContact
//

import Foundation

protocol AGESDate {
    var agesDateString: String { get }
}

extension CovidFallzahlen: AGESDate {
    var agesDateString: String {
        return self.meldeDatum
    }
}

extension CovidFaelleTimeline: AGESDate {
    var agesDateString: String {
        return self.time
    }
}
