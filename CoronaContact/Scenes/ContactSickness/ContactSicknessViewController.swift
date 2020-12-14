//
//  ContactSicknessViewController.swift
//  CoronaContact
//

import Reusable
import UIKit

final class ContactSicknessViewController: UIViewController, StoryboardBased, ViewModelBased, FlashableScrollIndicators {
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var headlineLabel: TransHeadingLabel!
    @IBOutlet var descriptionLabel: TransLabel!
    @IBOutlet var guidelinesHeadlineLabel: TransSubHeadingLabel!
    @IBOutlet var guidelinesEndOfQuarantineLabel: TransLabel!
    @IBOutlet var guidelinesDescriptionLabel: UILabel!
    @IBOutlet var guidelinesInstructionsView: InstructionsView!

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
