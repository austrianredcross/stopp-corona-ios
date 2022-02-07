//
//  SunDownerViewController.swift
//  CoronaContact
//

import Foundation
import UIKit
import Reusable

final class SunDownerViewController: UIViewController, StoryboardBased, ViewModelBased, FlashableScrollIndicators {
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var button: UIButton!
    
    var viewModel: SunDownerViewModel? {
        didSet {
            viewModel?.viewController = self
        }
    }
    var currentPage = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel?.setupViewController(self)
        setAccessibilityOrder()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        flashScrollIndicators()
    }
 
    func setPages(_ pages: [SunDownerPage]) {
        pages.forEach { page in
            let view = SunDownerPageView.loadFromNib()
            view.page = page
            view.newsletterCallback = newsletterIsPressed
            stackView.addArrangedSubview(view)
            view.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: 0).isActive = true
            view.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor, constant: 0).isActive = true
        }
        
        pageControl.numberOfPages = viewModel?.pageCount ?? 0
        scrollViewDidScroll(scrollView)
    }
    
    func updateButtonCaption(_ caption: String) {
        button.setAttributedTitle(caption.locaStyled(style: .primaryButton), for: .normal)
    }
    
    func scrollToPage(_ page: Int) {
        let width = Int(scrollView.frame.size.width)
        let target = CGPoint(x: width * page, y: 0)
        scrollView.setContentOffset(target, animated: true)
    }
    
    func newsletterIsPressed() {
        viewModel?.showNewsletter()
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        viewModel?.buttonPressed()
    }
    
    private func setAccessibilityOrder() {
        pageControl.isAccessibilityElement = false
        
        var accessViews = [UIView]()
        
        stackView.subviews.forEach({
            if let view = $0 as? SunDownerPageView {
                if let text = view.headingLabel.text, !text.isEmpty {
                    accessViews.append(view.headingLabel)
                }
                
                if let text = view.textLabel.text, !text.isEmpty {
                    accessViews.append(view.textLabel)
                }

                if view.imageView.image != nil {
                    accessViews.append(view.imageView)
                }
                
                if !view.newsletterButton.isHidden {
                    accessViews.append(view.newsletterButton)
                }
            }
        })
        
        accessViews.append(button)
        
        stackView.accessibilityElements = accessViews
    }

}

extension SunDownerViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let value = scrollView.contentOffset.x / scrollView.frame.size.width
        let currentPage = Int(round(value))
        pageControl.currentPage = currentPage
        if currentPage != self.currentPage {
            viewModel?.newPageShown(currentPage)
            self.currentPage = currentPage
        }
    }
}
