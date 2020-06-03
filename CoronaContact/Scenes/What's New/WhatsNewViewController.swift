//
//  WhatsNewViewController.swift
//  CoronaContact
//

import UIKit
import Reusable

class WhatsNewViewController: UIViewController, StoryboardBased {
    
    let viewModel = WhatsNewViewModel()
    
    @IBOutlet private weak var whatsNewLabel: TransLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        whatsNewLabel.attributedText = viewModel.whatsNewText?.locaStyled(style: .body)
    }
}
