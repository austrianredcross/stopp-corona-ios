//
//  WhatsNewViewController.swift
//  CoronaContact
//

import Reusable
import UIKit

class WhatsNewViewController: UIViewController, StoryboardBased {
    let viewModel = WhatsNewViewModel()
    weak var coordinator: WhatsNewCoordinator?

    @IBOutlet private var whatsNewLabel: TransLabel!
    @IBOutlet private var scrollView: UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()
        whatsNewLabel.attributedText = viewModel.whatsNewText?.locaStyled(style: .body)
    }

    func preferredHeight(forWidth width: CGFloat) -> CGFloat {
        view.layoutIfNeeded()
        return scrollView.contentSize.height
    }

    @IBAction func okButtonTapped(_ sender: Any) {
        coordinator?.dismiss()
    }
}
