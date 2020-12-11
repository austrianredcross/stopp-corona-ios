//
//  CheckboxLabelView.swift
//  CoronaContact
//

import Reusable
import UIKit

class CheckboxLabelView: UIView, NibOwnerLoadable {
    @IBOutlet var label: UILabel!
    @IBOutlet var checkbox: CheckboxView!

    @IBInspectable private var labelStyleName: String? {
        didSet {
            label?.styleName = labelStyleName
        }
    }

    @IBInspectable private var labelTransKey: String? {
        didSet {
            label?.text = labelTransKey?.localized
        }
    }

    @IBInspectable private var labelText: String? {
        didSet {
            label?.text = labelText
        }
    }

    var handleTap: ((Bool) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        loadNibContent()
        configureView()
        configureAccessibility()
    }

    private func configureView() {
        if let labelStyleName = labelStyleName {
            label.styleName = labelStyleName
        }

        if let labelTransKey = labelTransKey {
            label.text = labelTransKey.localized
        }

        if let labelText = labelText {
            label.text = labelText
        }

        // remove gesture recognizers to handle taps ourselves
        checkbox.gestureRecognizers?.forEach {
            checkbox.removeGestureRecognizer($0)
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(tappedView))
        isUserInteractionEnabled = true
        addGestureRecognizer(tap)
    }
    
    private func configureAccessibility() {
        isAccessibilityElement = true
        accessibilityElements = [label, checkbox]
        
        if let labelText = labelTransKey {
            accessibilityLabel = labelText.localized + " " + (checkbox.checkState == .checked ? "accessibility_activated".localized : "accessibility_deactivated".localized)
        }
        
        accessibilityHint = (checkbox.checkState == .checked ? "accessibility_double_tap_to_deactivate".localized : "accessibility_double_tap_to_activate".localized)
    }

    @objc
    private func tappedView(sender: Any) {
        checkbox.toggleCheckState(true)
        handleTap?(checkbox.checkState == .checked)
    }
    
    override func accessibilityActivate() -> Bool {
        
        let checkbox = accessibilityElement(at: 1) as? CheckboxView
        checkbox?.toggleCheckState()
        handleTap?(checkbox?.checkState == .checked)
        
        if let labelText = labelTransKey {
            accessibilityLabel = labelText.localized + " " + (checkbox!.checkState == .checked ? "accessibility_activated".localized : "accessibility_deactivated".localized)
            accessibilityHint = (checkbox!.checkState == .checked ? "accessibility_double_tap_to_deactivate".localized : "accessibility_double_tap_to_activate".localized)
        }
        
        return true
    }
}
