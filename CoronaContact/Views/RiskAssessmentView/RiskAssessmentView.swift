//
//  LabelSwitchWrapView.swift
//  CoronaContact
//

import Reusable
import UIKit

class RiskAssessmentView: UIStackView, NibOwnerLoadable {
    
    @IBOutlet var riskAssessmentTitleLabel: TransLabel!
    @IBOutlet var riskAssessmentCurrentStatusLabel: TransLabel!
    @IBOutlet var stackViewSwitch: UISwitch!
    
    @IBInspectable private var titleStyleName: String? {
        didSet {
            riskAssessmentTitleLabel?.styleName = titleStyleName
        }
    }

    @IBInspectable private var titleTransKey: String? {
        didSet {
            riskAssessmentTitleLabel?.text = titleTransKey?.localized
        }
    }

    @IBInspectable private var titleText: String? {
        didSet {
            riskAssessmentTitleLabel?.text = titleText
        }
    }
    
    private let titleIndex = 0
    private let switchIndex = 1
    
    var switchValueChanged: ((Bool) -> Void)?
        
    override func awakeFromNib() {
        super.awakeFromNib()
        
        loadNibContent()
        configureStackView()
    }
        
    private func configureStackView() {
        
        if let titleStyleName = titleStyleName {
            riskAssessmentTitleLabel.styleName = titleStyleName
        }

        if let titleTransKey = titleTransKey {
            riskAssessmentTitleLabel.text = titleTransKey.localized
        }

        if let titleText = titleText {
            riskAssessmentTitleLabel.text = titleText
        }
        
        isAccessibilityElement = true
        accessibilityElements = [riskAssessmentTitleLabel, stackViewSwitch]
        
        let switchValue = stackViewSwitch.isOn ? "accessibility_active".localized : "accessibility_inactive".localized
        
        if let titleTransKey = titleTransKey {
            accessibilityLabel = titleTransKey.localized + " " + switchValue.description
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
        
        if let titleTransKey = titleTransKey {
            accessibilityLabel = titleTransKey.localized + " " + switchValue
        }
        
        return true
    }
}
