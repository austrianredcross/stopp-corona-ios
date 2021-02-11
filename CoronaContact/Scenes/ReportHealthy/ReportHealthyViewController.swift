//
//  ReportHealthyViewController.swift
//  CoronaContact
//

import UIKit
import Reusable

class ReportHealthyViewController: UIViewController, StoryboardBased, ViewModelBased {

    var viewModel: ReportHealthyViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func quitQuarantineButtonPressed(_ sender: Any) {
        viewModel?.quitQuarantineButtonPressed()
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        viewModel?.cancelButtonPressed()
    }
}
