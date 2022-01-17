//
//  SavedIDsViewController.swift
//  CoronaContact
//

import Reusable
import UIKit

final class SavedIDsViewController: UIViewController, StoryboardBased, ViewModelBased, FlashableScrollIndicators {
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var stackView: UIStackView!
    
    var viewModel: SavedIDsViewModel?

    var instructions: [Instruction] = [
        Instruction(index: 1, text: "saved_IDs_delete_content_1".localized, instructionIcon: InstructionIcons.none),
        Instruction(index: 2, text: "saved_IDs_delete_content_2".localized, instructionIcon: InstructionIcons.none),
        Instruction(index: 3, text: "saved_IDs_delete_content_3".localized, instructionIcon: InstructionIcons.none),
        Instruction(index: 4, text: "saved_IDs_delete_content_4".localized, instructionIcon: InstructionIcons.none),
        Instruction(index: 5, text: "saved_IDs_delete_content_5".localized, instructionIcon: InstructionIcons.none)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        flashScrollIndicators()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if navigationController == nil {
            viewModel?.finish()
        }
    }

    private func setupUI() {
        title = "saved_IDs_title".localized

        addInstructions()
    }
    
    private func addInstructions() {
        instructions.forEach({ instruction in
            
            let bubbleView = BubbleView()
            bubbleView.text = String(instruction.index)
            bubbleView.backgroundColor = .clear
            bubbleView.bubbleColor = .ccRedButton
            bubbleView.textColour = .ccWhiteText
            
            let spacing: CGFloat = 16
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
                label.topAnchor.constraint(equalTo: paddingView.topAnchor, constant: spacing),
                label.bottomAnchor.constraint(equalTo: paddingView.bottomAnchor),
            ])
            
            let instructionStackView = UIStackView(arrangedSubviews: [
                bubbleView,
                paddingView,
            ])
            instructionStackView.spacing = spacing
            instructionStackView.alignment = .top
            instructionStackView.axis = .horizontal
            
            instructionStackView.isAccessibilityElement = true
            instructionStackView.accessibilityLabel = String(instruction.index) + "instruction_step".localized
            instructionStackView.accessibilityValue = instruction.text
            
            stackView.addArrangedSubview(instructionStackView)
            
        })
    }
}
