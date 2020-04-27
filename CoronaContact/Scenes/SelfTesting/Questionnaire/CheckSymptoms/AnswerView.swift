//
//  AnswerView.swift
//  CoronaContact
//

import UIKit
import Reusable
import M13Checkbox

class AnswerView: UIView, NibLoadable {

    @IBOutlet private weak var checkbox: M13Checkbox!
    @IBOutlet private weak var answerLabel: UILabel!

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
        checkbox.tintColor = .ccRouge
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

    func configure(with answer: Answer) {
        text = answer.text
    }

    @objc
    private func tappedView(sender: Any) {
        handleTap?()
    }

    func setSelectedState(_ value: Bool, animated: Bool = true) {
        if value {
            checkbox.setCheckState(.checked, animated: animated)
        } else {
            checkbox.setCheckState(.unchecked, animated: animated)
        }
    }
}
