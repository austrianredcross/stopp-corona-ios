//
//  ContactHelpViewController.swift
//  CoronaContact
//

import UIKit
import Reusable

final class ContactHelpViewController: UIViewController,
    StoryboardBased, ViewModelBased, FlashableScrollIndicators {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var instructionsView: InstructionsView!

    var viewModel: ContactHelpViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        flashScrollIndicators()
    }

    private func setupUI() {
        innerView.layer.cornerRadius = 8
        innerView.addShadow(
            ofColor: UIColor.ccBlack,
            radius: 8,
            offset: CGSize(width: 2, height: 2),
            opacity: 0.23
        )

        instructionsView.instructions = [
            .init(index: 1, text: "contact_help_instruction_first".localized),
            .init(index: 2, text: "contact_help_instruction_second".localized),
            .init(index: 3, text: "contact_help_instruction_third".localized)
        ]
    }

    @IBAction func faqButtonTapped(_ sender: Any) {
        viewModel?.openFAQ()
    }

    @IBAction func closeButtonTapped(_ sender: Any) {
        viewModel?.close()
    }
}
