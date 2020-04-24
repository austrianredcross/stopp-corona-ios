//
//  AttestedSicknessGuidelinesViewController.swift
//  CoronaContact
//

import UIKit
import Reusable

final class AttestedSicknessGuidelinesViewController: UIViewController, StoryboardBased, ViewModelBased, FlashableScrollIndicators {
    var viewModel: AttestedSicknessGuidelinesViewModel?

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var instructionsView: InstructionsView!
    @IBOutlet weak var attestedSicknessDateLabel: TransLabel!

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
            .init(index: 4, text: "sickness_certificate_quarantine_guidelines_steps_fourth".localized)
        ]
    }
}
