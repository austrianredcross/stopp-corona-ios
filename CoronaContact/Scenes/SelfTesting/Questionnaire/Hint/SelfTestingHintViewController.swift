//
//  SelfTestingHintViewController.swift
//  CoronaContact
//

import Reusable
import UIKit

final class SelfTestingHintViewController: UIViewController, StoryboardBased, ViewModelBased, FlashableScrollIndicators {
    @IBOutlet var scrollView: UIScrollView!

    var viewModel: SelfTestingHintViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel?.onViewDidLoad()
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

    @IBAction func doneTapped(_ sender: UIButton) {
        viewModel?.returnToMain()
    }
}
