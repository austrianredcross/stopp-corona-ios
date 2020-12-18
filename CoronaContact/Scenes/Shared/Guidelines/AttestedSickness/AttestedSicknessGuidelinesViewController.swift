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
        
        if let guidelines = viewModel?.guidelines {
            instructionsView.instructions = guidelines
        } else {
            instructionsView.isHidden = true
        }
    }
}
