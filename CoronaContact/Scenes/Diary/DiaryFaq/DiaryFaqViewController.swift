//
//  DiaryFaqViewController.swift
//  CoronaContact
//

import Reusable
import UIKit

class DiaryFaqViewController: UIViewController, StoryboardBased, ViewModelBased {
        
    var viewModel: DiaryFaqViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    func setupUI() {
        title = "dairy_faq_title".localized
    }
}
