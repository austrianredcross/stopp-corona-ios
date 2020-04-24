//
//  SelfTestingSuspicionViewController.swift
//  CoronaContact
//

import UIKit
import Reusable

final class SelfTestingSuspicionViewController: UIViewController, StoryboardBased, ViewModelBased, FlashableScrollIndicators {

    @IBOutlet weak var scrollView: UIScrollView!

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
