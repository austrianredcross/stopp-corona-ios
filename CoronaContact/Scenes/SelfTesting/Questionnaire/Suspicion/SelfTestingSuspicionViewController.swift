//
//  SelfTestingSuspicionViewController.swift
//  CoronaContact
//

import Reusable
import UIKit

final class SelfTestingSuspicionViewController: UIViewController, StoryboardBased, ViewModelBased, FlashableScrollIndicators {
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet weak var selfTestingResultLabel: TransHeadingLabel!
    @IBOutlet weak var selfTestingSuspicionHeadlineLabel: TransHeadingLabel!
    @IBOutlet weak var selfTestingStackView: UIStackView!
    var viewModel: SelfTestingSuspicionViewModel?

    @IBAction func buttonTapped(_ sender: UIButton) {
        viewModel?.report()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        flashScrollIndicators()
        
        selfTestingStackView.accessibilityElements = [selfTestingResultLabel, selfTestingSuspicionHeadlineLabel]
        selfTestingStackView.isAccessibilityElement = true
        selfTestingStackView.accessibilityLabel = selfTestingResultLabel.text! + " " + selfTestingSuspicionHeadlineLabel.text!
        selfTestingStackView.accessibilityTraits = .header
    }

    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        if parent == nil {
            viewModel?.viewClosed()
        }
    }
}
