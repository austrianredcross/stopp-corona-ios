//
//  SelfMonitoringGuidelinesViewController.swift
//  CoronaContact
//

import Reusable
import UIKit

final class SelfMonitoringGuidelinesViewController: UIViewController, StoryboardBased, ViewModelBased, FlashableScrollIndicators {
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var formFilledDateLabel: TransLabel!
    @IBOutlet var instructionsView: InstructionsView!

    var viewModel: SelfMonitoringGuidelinesViewModel?

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
        title = "self_monitoring_guidelines_title".localized

        instructionsView.instructions = [
            .init(index: 1, text: "self_monitoring_guidelines_next_steps_first".localized, instructionIcon: InstructionIcons.thermometer),
            .init(index: 2, text: "self_monitoring_guidelines_next_steps_second".localized, instructionIcon: InstructionIcons.pcr),
            .init(index: 3, text: "self_monitoring_guidelines_next_steps_third".localized, instructionIcon: InstructionIcons.distance),
        ]

        if let date = viewModel?.dateLabel {
            formFilledDateLabel.styledText = String(format: "self_monitoring_guidelines_form_filled_date".localized, date)
        }
    }

    @IBAction func buttonTapped(_ sender: Any) {
        viewModel?.buttonTapped()
    }
}
