//
//  UIScrollView+ScrollToVisible.swift
//  CoronaContact
//

import UIKit

/**
 Marks conforming views as scrolling targets

 Use this protocol with `UIScrollView.scrollToCurrentlyActiveView(animated:)`.

 **Use case:** A scrollView contains multiple views. Some views contain text fields.
 `scrollToCurrentlyActiveView(animated:)` moves the currently selected text field
 into the visible portion of the scrollView. However, it will scroll without any
 margin, causing the textField to be right at the scrollView's edge.

 If a view containing the textField conforms to `ScrollableToVisible`, this view
 will be used for scrolling instead.
 */
@objc protocol ScrollableToVisible {}

extension UIScrollView {
    /**
     Scrolls to the currently active descendant view

     The currently active view is:
      - the first ancestor of the first responder that conforms to `ScrollableToVisible` if available
      - otherwise the first responder
     */
    func scrollToCurrentlyActiveView(animated: Bool) {
        guard let firstResponder = firstResponder else {
            return
        }
        let scrollable = firstResponder.first(ofType: (UIView & ScrollableToVisible).self, stopAt: self)
        let target = scrollable ?? firstResponder
        let targetRect = convert(target.frame, from: target.superview)
        scrollRectToVisible(targetRect, animated: animated)
    }
}
