//
//  AnswerView.swift
//  CoronaContact
//

import M13Checkbox
import Reusable
import UIKit

class AnswerView: UIView, NibLoadable {
    @IBOutlet private var checkbox: M13Checkbox!
    @IBOutlet private var answerLabel: UILabel!

    var text: String = "" {
        didSet {
            answerLabel.text = text
        }
    }

    var handleTap: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()

        configureView()
    }

    private func configureView() {
        checkbox.boxType = .circle
        checkbox.markType = .radio
        checkbox.stateChangeAnimation = .bounce(.fill)
        checkbox.tintColor = .ccRedText
        checkbox.checkmarkLineWidth = 3
        checkbox.boxLineWidth = 1
        checkbox.secondaryTintColor = .ccBlack

        // remove gesture recognizers to handle taps ourselves
        checkbox.gestureRecognizers?.forEach {
            checkbox.removeGestureRecognizer($0)
        }

        let tap = UITapGestureRecognizer(target: self, action: #selector(tappedView))
        isUserInteractionEnabled = true
        addGestureRecognizer(tap)
    }
    
    private func configureAccessibility() {
        
        accessibilityElements = [checkbox, answerLabel]
        isAccessibilityElement = true
        accessibilityLabel = text + " " + "accessibility_deactivated".localized
        accessibilityHint = "accessibility_double_tap_to_activate".localized
    }

    func configure(with answer: Answer) {
        text = answer.text
        configureAccessibility()
    }

    @objc
    private func tappedView(sender: Any) {
        handleTap?()
    }

    func setSelectedState(_ value: Bool, animated: Bool = true) {
        if value {
            accessibilityLabel = text + " " + "accessibility_activated".localized
            accessibilityHint = nil
            checkbox.setCheckState(.checked, animated: animated)
        } else {
            accessibilityLabel = text + " " + "accessibility_deactivated".localized
            accessibilityHint = "accessibility_double_tap_to_activate".localized
            checkbox.setCheckState(.unchecked, animated: animated)
        }
    }
    
    override func accessibilityActivate() -> Bool {
        handleTap?()
        return true
    }
}
