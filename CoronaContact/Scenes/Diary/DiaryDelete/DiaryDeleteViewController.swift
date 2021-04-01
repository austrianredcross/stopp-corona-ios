//
//  DiaryDeleteViewController.swift
//  CoronaContact
//

import Reusable
import UIKit
import CoreData

class DiaryDeleteViewController: UIViewController, StoryboardBased, ViewModelBased {
        
    var viewModel: DiaryDeleteViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func deleteButtonPressed() {
        viewModel?.deletePressed()
    }
    
    @IBAction func cancelButtonPressed() {
        viewModel?.cancelPressed()
    }
}
