//
//  InstructionsView.swift
//  CoronaContact
//

import UIKit

struct Instruction {
    let index: Int
    let text: String
}

class BubbleView: UIView {
    private var innerWrapperView: UIView!
    private var label: UILabel!

    var bubbleColor: UIColor = .white {
        didSet {
            innerWrapperView.backgroundColor = bubbleColor
        }
    }

    var bubbleSize: CGFloat = 56
    var insets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    var text: String = "" {
        didSet {
            label.text = text
        }
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
        configureInnerWrapper()
        configureLabel()
    }

    private func configureInnerWrapper() {
        innerWrapperView = UIView()
        innerWrapperView.backgroundColor = bubbleColor
        innerWrapperView.translatesAutoresizingMaskIntoConstraints = false
        innerWrapperView.layer.cornerRadius = bubbleSize / 2

        addSubview(innerWrapperView)

        NSLayoutConstraint.activate([
            innerWrapperView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: insets.left),
            trailingAnchor.constraint(equalTo: innerWrapperView.trailingAnchor, constant: insets.right),
            innerWrapperView.topAnchor.constraint(equalTo: topAnchor, constant: insets.top),
            bottomAnchor.constraint(equalTo: innerWrapperView.bottomAnchor, constant: insets.bottom),
            innerWrapperView.widthAnchor.constraint(equalToConstant: bubbleSize),
            innerWrapperView.heightAnchor.constraint(equalToConstant: bubbleSize),
        ])
    }

    private func configureLabel() {
        label = UILabel()
        label.text = text
        label.textColor = .ccRouge
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
}

class InstructionsView: UIView {
    @IBInspectable private var bubbleColor: UIColor = .white

    private var stackView: UIStackView!
    private var lineView: UIView!

    var instructions: [Instruction] = [] {
        didSet {
            configureInstructions()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        configureView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        updateConnectingLine()
    }

    private func configureView() {
        configureStackView()
        configureConnectingLine()

        setNeedsLayout()
        layoutIfNeeded()
    }

    private func configureStackView() {
        stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    private func configureInstructions() {
        instructions.forEach(addInstruction)

        stackView.addArrangedSubview(UIView())
    }

    private func addInstruction(_ instruction: Instruction) {
        let bubbleView = BubbleView()
        bubbleView.text = String(instruction.index)
        bubbleView.backgroundColor = backgroundColor
        bubbleView.bubbleColor = bubbleColor

        let paddingView = UIView()
        let label = TransLabel()
        label.text = instruction.text
        label.styleName = "body"
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)

        paddingView.addSubview(label)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: paddingView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: paddingView.trailingAnchor),
            label.topAnchor.constraint(equalTo: paddingView.topAnchor, constant: 16),
            label.bottomAnchor.constraint(equalTo: paddingView.bottomAnchor),
        ])

        let instructionStackView = UIStackView(arrangedSubviews: [
            bubbleView,
            paddingView,
        ])
        instructionStackView.spacing = 16
        instructionStackView.alignment = .top
        instructionStackView.axis = .horizontal

        stackView.addArrangedSubview(instructionStackView)
    }

    private func configureConnectingLine() {
        lineView = UIView()
        lineView.backgroundColor = .black
        lineView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(lineView)
        sendSubviewToBack(lineView)
    }

    private func updateConnectingLine() {
        var centerXOfBubble: CGFloat?
        let centerYCoordinatesOfBubbles = instructions
            .enumerated()
            .compactMap { (index, _) -> CGFloat? in
                guard let instructionStackView = stackView.arrangedSubviews[index] as? UIStackView else {
                    return nil
                }

                let bubbleView = instructionStackView.arrangedSubviews[0]

                bubbleView.setNeedsLayout()
                bubbleView.layoutIfNeeded()

                let rect = bubbleView.convert(bubbleView.frame, to: self)

                centerXOfBubble = rect.midX

                return rect.midY
            }

        guard let centerX = centerXOfBubble,
            let minY: CGFloat = centerYCoordinatesOfBubbles.min(),
            let maxY: CGFloat = centerYCoordinatesOfBubbles.max()
        else {
            return
        }

        let width: CGFloat = 1.0 / UIScreen.main.scale
        let height: CGFloat = maxY - minY

        lineView.frame = CGRect(x: centerX, y: minY, width: width, height: height)
    }
}
