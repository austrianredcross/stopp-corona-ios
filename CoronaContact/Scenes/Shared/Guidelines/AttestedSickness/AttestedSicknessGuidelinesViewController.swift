//
//  AttestedSicknessGuidelinesViewController.swift
//  CoronaContact
//

import Reusable
import UIKit

final class AttestedSicknessGuidelinesViewController: UIViewController, StoryboardBased, ViewModelBased, FlashableScrollIndicators {
    var viewModel: AttestedSicknessGuidelinesViewModel?

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var instructionsView: InstructionsView!
    @IBOutlet var attestedSicknessDateLabel: TransLabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        flashScrollIndicators()
    }

    private func setupUI() {
        title = "sickness_certificate_quarantine_guidelines_title".localized

        if let attestedSicknessAt = viewModel?.attestedSicknessAt {
            attestedSicknessDateLabel.styledText = String(format: "sickness_certificate_quarantine_guidelines_date".localized, attestedSicknessAt)
        }

        instructionsView.instructions = [
            .init(index: 1, text: "sickness_certificate_quarantine_guidelines_steps_first".localized),
            .init(index: 2, text: "sickness_certificate_quarantine_guidelines_steps_second".localized),
            .init(index: 3, text: "sickness_certificate_quarantine_guidelines_steps_third".localized),
            .init(index: 4, text: "sickness_certificate_quarantine_guidelines_steps_fourth".localized),
        ]
    }
}
