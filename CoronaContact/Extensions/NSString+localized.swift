//
//  NSString+localized.swift
//  CoronaContact
//

import UIKit

extension String {
    var localized: String {
        NSLocalizedString(self, comment: "").replacingOccurrences(of: "%s", with: "%@")
    }

    func locaStyled(style: StyleNames) -> NSAttributedString? {
        localized.set(style: style.rawValue, range: nil)
    }
    
    func ranges(regex pattern: String) -> [Range<Index>] {
        var ranges: [Range<Index>] = []
        
        while ranges.last.map({ $0.upperBound < endIndex}) ?? true,
              let range = range(of: pattern, options: .regularExpression, range: (ranges.last?.upperBound ?? startIndex)..<endIndex) {
            ranges.append(range)
        }
        return ranges
    }
}
