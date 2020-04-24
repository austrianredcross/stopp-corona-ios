//
//  CheckboxView.swift
//  CoronaContact
//

import UIKit
import M13Checkbox

class CheckboxView: M13Checkbox {

    override var isEnabled: Bool {
        didSet {
            configureCurrentState()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        configureView()
    }

    private func configureView() {
        boxType = .square
        markType = .checkmark
        stateChangeAnimation = .bounce(.fill)
        checkmarkLineWidth = 2
        boxLineWidth = 2
        secondaryTintColor = .black

        configureCurrentState()
    }

    private func configureCurrentState() {
        if isEnabled {
            configureEnabledState()
        } else {
            configureDisabledState()
        }
    }

    private func configureEnabledState() {
        tintColor = .ccRouge
    }

    private func configureDisabledState() {
        tintColor = .ccCheckboxInactive
    }
}
