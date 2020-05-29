//
//  SelfTestingSuspicionViewController.swift
//  CoronaContact
//

import Reusable
import UIKit

final class SelfTestingSuspicionViewController: UIViewController, StoryboardBased, ViewModelBased, FlashableScrollIndicators {
    @IBOutlet var scrollView: UIScrollView!

    var viewModel: SelfTestingSuspicionViewModel?

    @IBAction func buttonTapped(_ sender: UIButton) {
        viewModel?.report()
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
}
