//
//  NSString+localized.swift
//  CoronaContact
//

import UIKit

extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }

    func locaStyled(style: StyleNames) -> NSAttributedString? {
        self.localized.set(style: style.rawValue, range: nil)
    }

}
