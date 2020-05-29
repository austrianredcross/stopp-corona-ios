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
}
