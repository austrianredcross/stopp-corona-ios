//
//  FlashableScrollIndicators.swift
//  CoronaContact
//

import UIKit

protocol FlashableScrollIndicators {
    /// Flash scrolling indicators after the specified time
    var flashScrollIndicatorsAfter: DispatchTimeInterval { get }
    var scrollView: UIScrollView! { get }

    func flashScrollIndicators()
}

extension FlashableScrollIndicators where Self: UIViewController {
    var flashScrollIndicatorsAfter: DispatchTimeInterval {
        .milliseconds(500)
    }

    func flashScrollIndicators() {
        DispatchQueue.main.asyncAfter(deadline: .now() + flashScrollIndicatorsAfter) {
            self.scrollView.flashScrollIndicators()
        }
    }
}
