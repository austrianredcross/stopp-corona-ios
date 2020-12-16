//
//  QuarantineGuidelinesViewController.swift
//  CoronaContact
//

import Reusable
import UIKit

final class QuarantineGuidelinesViewController: UIViewController, StoryboardBased, ViewModelBased, FlashableScrollIndicators {
    var viewModel: QuarantineGuidelinesViewModel?

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var instructionsView: InstructionsView!
    @IBOutlet var contactHealthDescriptionLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        flashScrollIndicators()
    }
    
    private func setupUI() {
        title = "quarantine_guidelines_title".localized

        if let guidelines = viewModel?.guidelines {
            instructionsView.instructions = guidelines
        } else {
            instructionsView.isHidden = true
        }
    }
}
