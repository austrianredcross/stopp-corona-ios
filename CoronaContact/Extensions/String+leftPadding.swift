//
//  String+leftPadding.swift
//  CoronaContact
//

import Foundation

//Source: https://stackoverflow.com/questions/32338137/padding-a-swift-string-for-printing
extension String {
    func leftPadding(toLength: Int, withPad character: Character) -> String? {
        let newLength = self.count
        if newLength < toLength {
            return String(repeatElement(character, count: toLength - newLength)) + self
        } else {
            return self.substring(from: newLength - toLength, length: newLength)
        }
    }
}
