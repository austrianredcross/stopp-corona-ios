//
//  FullExposure.swift
//  CoronaContact
//

import Foundation

enum FullExposure {
    case sevenDays(Date, Bool)
    case fourteenDays(DailyExposure?)
}
