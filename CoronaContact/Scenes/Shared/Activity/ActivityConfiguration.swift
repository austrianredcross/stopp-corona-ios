//
//  ActivityConfiguration.swift
//  CoronaContact
//

import Foundation

struct ActivityConfiguration {
    let text: String?
    let style: ActivityStyle
    let presentationStyle: ActivityPresentationStyle

    init(text: String? = nil, style: ActivityStyle, presentationStyle: ActivityPresentationStyle) {
        self.text = text
        self.style = style
        self.presentationStyle = presentationStyle
    }
}
