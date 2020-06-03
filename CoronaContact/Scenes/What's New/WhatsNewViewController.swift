//
//  WhatsNewViewController.swift
//  CoronaContact
//

import UIKit
import Reusable

class WhatsNewViewController: UIViewController, StoryboardBased {
    
    let viewModel = WhatsNewViewModel()
    
    @IBOutlet private weak var whatsNewLabel: TransLabel!
    @IBOutlet private weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        whatsNewLabel.attributedText = viewModel.whatsNewText?.locaStyled(style: .body)
    }
    
    func preferredHeight(forWidth width: CGFloat) -> CGFloat {
        view.layoutIfNeeded()
        return scrollView.contentSize.height
    }
}
