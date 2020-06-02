//
//  ProgressView.swift
//  CoronaContact
//

import UIKit

@IBDesignable
class ProgressView: UIView {
    @IBInspectable var numberOfSteps: Int = 3 {
        didSet {
            configureSteps()
        }
    }

    @IBInspectable var currentStep: Int = 0 {
        didSet {
            updateCurrentStep()
        }
    }

    private var stackView: UIStackView!
    private var stepsViews: [UIView] = []
    private var label: UILabel!

    private var labelText: String {
        String(format: "sickness_certificate_progress_label".localized, currentStep + 1, numberOfSteps)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        configureView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        configureView()
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        configureView()
    }

    private func configureView() {
        configureStackView()
        configureSteps()
        configureLabel()
    }

    private func configureStackView() {
        stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 8),
        ])
    }

    private func configureSteps() {
        stackView?.arrangedSubviews.forEach { view in
            view.removeFromSuperview()
        }
        stepsViews = []

        for _ in 0 ..< numberOfSteps {
            addStep()
        }

        updateCurrentStep()
    }

    private func configureLabel() {
        label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.text = labelText
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)

        NSLayoutConstraint.activate([
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
            label.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 4),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    private func addStep() {
        let stepView = UIView()
        stepView.backgroundColor = .gray

        stackView.addArrangedSubview(stepView)
        stepsViews.append(stepView)
    }

    private func updateCurrentStep() {
        guard currentStep < numberOfSteps else {
            return
        }

        stepsViews.enumerated().forEach { index, stepView in
            if currentStep >= index {
                stepView.backgroundColor = .ccRouge
            } else {
                stepView.backgroundColor = .gray
            }
        }

        label?.text = labelText
    }

    func nextStep() {
        currentStep += 1
    }
}
