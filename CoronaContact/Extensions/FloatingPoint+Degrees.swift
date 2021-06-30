//
//  FloatingPoint+Degrees.swift
//  CoronaContact
//

import Foundation

extension FloatingPoint {
    var degreesToRadians: Self { self * .pi / 180 }
    var radiansToDegrees: Self { self * 180 / .pi }
}
