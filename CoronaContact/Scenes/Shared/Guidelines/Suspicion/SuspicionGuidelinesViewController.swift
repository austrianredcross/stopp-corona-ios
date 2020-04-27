//
//  SuspicionGuidelinesViewController.swift
//  CoronaContact
//

import UIKit
import Reusable

final class SuspicionGuidelinesViewController: UIViewController, StoryboardBased, ViewModelBased, FlashableScrollIndicators {
    var viewModel: SuspicionGuidelinesViewModel?

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var endOfQuarantineLabel: TransLabel!
    @IBOutlet weak var instructionsView: InstructionsView!

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
        title = "suspicion_guidelines_title".localized

        endOfQuarantineLabel.styledText = viewModel?.endOfQuarantine
        instructionsView.instructions = [
            .init(index: 1, text: "suspicion_guidelines_precaution_first".localized),
            .init(index: 2, text: "suspicion_guidelines_precaution_second".localized),
            .init(index: 3, text: "suspicion_guidelines_precaution_third".localized),
            .init(index: 4, text: "suspicion_guidelines_precaution_fourth".localized)
        ]
    }

    @IBAction func buttonTapped(_ sender: Any) {
        viewModel?.buttonTapped()
    }
}
