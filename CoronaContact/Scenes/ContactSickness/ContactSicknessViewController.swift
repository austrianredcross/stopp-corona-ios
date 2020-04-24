//
//  ContactSicknessViewController.swift
//  CoronaContact
//

import UIKit
import Reusable

final class ContactSicknessViewController: UIViewController, StoryboardBased, ViewModelBased, FlashableScrollIndicators {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var headlineLabel: UILabel!
    @IBOutlet weak var descriptionLabel: TransLabel!
    @IBOutlet weak var guidelinesHeadlineLabel: UILabel!
    @IBOutlet weak var guidelinesEndOfQuarantineLabel: TransLabel!
    @IBOutlet weak var guidelinesDescriptionLabel: UILabel!
    @IBOutlet weak var guidelinesInstructionsView: InstructionsView!

    var viewModel: ContactSicknessViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        flashScrollIndicators()
    }

    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        if parent == nil {
            viewModel?.viewClosed()
        }
    }

    private func setupUI() {
        title = viewModel?.title
        headlineLabel.text = viewModel?.headline
        descriptionLabel.styledText = viewModel?.description
        guidelinesHeadlineLabel.text = viewModel?.headlineGuidelines
        guidelinesEndOfQuarantineLabel.styledText = viewModel?.endOfQuarantine
        guidelinesDescriptionLabel.text = viewModel?.descriptionGuidelines

        if let instructions = viewModel?.guidelines {
            guidelinesInstructionsView.instructions = instructions
        } else {
            guidelinesInstructionsView.isHidden = true
        }
    }
}
