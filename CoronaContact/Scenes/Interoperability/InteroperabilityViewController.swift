//
//  InteroperabilityViewController.swift
//  CoronaContact
//

import UIKit
import Reusable

final class InteroperabilityViewController: UIViewController, StoryboardBased, ViewModelBased {

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var linkTextView: LinkTextView!
    
    var viewModel: InteroperabilityViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTextView()
    }
    
    private func configureTextView() {
        linkTextView.textViewAttribute = TextViewAttribute(fullText: "interoperability_terms_of_use_faq_content".localized, links: [DeepLinkConstants.deepLinkPrivacyUrl, DeepLinkConstants.deepLinkFAQUrl], linkColor: .ccLink)
    }
    
    @IBAction func acceptButtonPressed(_ sender: Any) {
        viewModel?.agreedButtonPressed()
    }
}
