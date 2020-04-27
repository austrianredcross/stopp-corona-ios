//
//  KeyboardAdjustingBehavior.swift
//  CoronaContact
//

import UIKit

/**
 Adds keyboard adjustments to the given scrollView

 Adjustments when the keyboard appears:
 - The scrollView's bottom content inset is adjusted to add room for the keyboard
 - Any active view is scrolled into the visible area.
   Active views are either the current first responder, or an ancestor
   of the first responder that conforms to `ScrollableToVisible`

 Adjustments when the keyboard disappears:
 - The scrollView's bottom content inset is adjusted to remove the extra keyboard space

 **Usage (programmatically):**
 - Simply instantiate with the scroll view
 - Keep a strong reference to prevent premature deallocation

 **NOTE: (ahan, 2019-11-04) Using interface builder does not seem to work.**

 **Usage (Interface Builder):**
 - Add an Object to your scene
 - Set its class to `KeyboardAdjustingBehavior`
 - connect the `scrollView` outlet
 - connect an outlet in your ViewController to the KeyboardAdjustingBehavior object to prevent premature deallocation
 */
public class KeyboardAdjustingBehavior: NSObject {
    @IBOutlet public weak var scrollView: UIScrollView!
    public var keyboardPadding: CGFloat = 0

    public var keyboardObserverTokens: [NotificationToken] = []

    public init(scrollView: UIScrollView) {
        self.scrollView = scrollView
        super.init()
        addKeyboardObservers()
    }

    private func addKeyboardObservers() {
        let notificationCenter = NotificationCenter.default

        let keyboardShowToken = notificationCenter.observe(
            name: UIResponder.keyboardWillShowNotification,
            object: nil, queue: nil) { [weak self] in
                self?.keyboardWillShow(notification: $0)
        }

        let keyboardHideToken = notificationCenter.observe(
            name: UIResponder.keyboardWillHideNotification,
            object: nil, queue: nil) { [weak self] in
                self?.keyboardWillHide(notification: $0)
        }

        keyboardObserverTokens = [keyboardShowToken, keyboardHideToken]
    }

    private func keyboardWillShow(notification: Notification) {
        guard let userInfo = notification.userInfo else {
            return
        }
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = scrollView.convert(keyboardScreenEndFrame, from: scrollView.window)

        var insets = scrollView.contentInset
        insets.bottom = keyboardViewEndFrame.size.height + keyboardPadding
        scrollView.contentInset = insets

        // Also adjust scroll indicator but ignore the padding otherwise they might show a gap
        insets = scrollView.scrollIndicatorInsets
        insets.bottom = keyboardViewEndFrame.size.height
        scrollView.scrollIndicatorInsets = insets

        let curveValue = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)!.intValue
        let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)!.doubleValue

        UIView.animate(withDuration: duration,
                       delay: 0,
                       options: UIView.AnimationOptions(rawValue: UIView.AnimationOptions.RawValue(curveValue)),
                       animations: {
                                       self.scrollView.scrollToCurrentlyActiveView(animated: false)
                                   },
                       completion: nil)
    }

    private func keyboardWillHide(notification: Notification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }
}
