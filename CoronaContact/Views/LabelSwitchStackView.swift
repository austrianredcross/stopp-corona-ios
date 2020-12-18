//
//  LabelSwitchWrapView.swift
//  CoronaContact
//

import Reusable
import UIKit

class LabelSwitchStackView: UIStackView, NibOwnerLoadable {
    
    @IBOutlet var stackViewLabel: TransLabel!
    @IBOutlet var stackViewSwitch: UISwitch!
    
    @IBInspectable private var labelStyleName: String? {
        didSet {
            stackViewLabel?.styleName = labelStyleName
        }
    }

    @IBInspectable private var labelTransKey: String? {
        didSet {
            stackViewLabel?.text = labelTransKey?.localized
        }
    }

    @IBInspectable private var labelText: String? {
        didSet {
            stackViewLabel?.text = labelText
        }
    }
    
    private let labelIndex = 0
    private let switchIndex = 1
    
    var switchValueChanged: ((Bool) -> Void)?
        
    override func awakeFromNib() {
        super.awakeFromNib()
        
        loadNibContent()
        configureStackView()
    }
        
    private func configureStackView() {
        
        if let labelStyleName = labelStyleName {
            stackViewLabel.styleName = labelStyleName
        }

        if let labelTransKey = labelTransKey {
            stackViewLabel.text = labelTransKey.localized
        }

        if let labelText = labelText {
            stackViewLabel.text = labelText
        }
        
        isAccessibilityElement = true
        accessibilityElements = [stackViewLabel, stackViewSwitch]
        
        let switchValue = stackViewSwitch.isOn ? "accessibility_active".localized : "accessibility_inactive".localized
        
        if let labelText = labelTransKey {
            accessibilityLabel = labelText.localized + " " + switchValue.description
        }
        
        accessibilityHint = "accessibility_double_tap_to_switch".localized
    }
    
    @IBAction func backgroundHandshakeSwitchValueChanged(_ sender: UISwitch) {
        switchValueChanged?(sender.isOn)
    }
    
    override func accessibilityActivate() -> Bool {
        
        guard let aSwitch = accessibilityElement(at: switchIndex) as? UISwitch else { return true }
        aSwitch.setOn(!aSwitch.isOn, animated: false)
        switchValueChanged?(aSwitch.isOn)
        
        let switchValue = aSwitch.isOn ? "accessibility_active".localized : "accessibility_inactive".localized
        
        if let labelText = labelTransKey {
            accessibilityLabel = labelText.localized + " " + switchValue
        }
        
        return true
    }
}
