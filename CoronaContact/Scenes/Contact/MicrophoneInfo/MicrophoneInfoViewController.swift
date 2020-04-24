//
//  MicrophoneInfoViewController.swift
//  CoronaContact
//

import UIKit
import Reusable

final class MicrophoneInfoViewController: UIViewController, StoryboardBased, ViewModelBased, FlashableScrollIndicators {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var innerView: UIView!
    @IBOutlet weak var checkboxView: CheckboxView!

    var viewModel: MicrophoneInfoViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        innerView.layer.cornerRadius = 8.0
        innerView.addStandardShadow()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        flashScrollIndicators()
    }

    @IBAction func closeButtonTapped(_ sender: Any) {
        viewModel?.close()
    }

    @IBAction func hideNextTimeButtonChanged(_ sender: Any) {
        checkboxView.toggleCheckState(true)
        hideNextTimeCheckboxChanged(checkboxView)
    }

    @IBAction func hideNextTimeCheckboxChanged(_ sender: CheckboxView) {
        viewModel?.hideNextTimeCheckboxChanged(isChecked: sender.checkState == .checked)
    }
}
