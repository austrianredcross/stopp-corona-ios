//
//  OnboardingViewController.swift
//  CoronaContact
//

import Reusable
import UIKit

final class OnboardingViewController: UIViewController, StoryboardBased, ViewModelBased, FlashableScrollIndicators {
    var viewModel: OnboardingViewModel? {
        didSet {
            viewModel?.viewController = self
        }
    }

    var currentPage = -1

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var pageControl: UIPageControl!
    @IBOutlet var button: UIButton!

    public var isButtonEnabled: Bool {
        get { button.isEnabled }
        set {
            button.isEnabled = newValue
            button.accessibilityHint = newValue ? nil : "accessibility_onboarding_finish_button_disabled_description".localized
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel?.setupViewController(self)
        setAccessibilityOrder()
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

    func setOnboardingPages(_ pages: [OnboardingPage]) {
        pages.forEach { page in
            let view = OnboardingPageView.loadFromNib()
            view.page = page
            stackView.addArrangedSubview(view)
            view.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: 0).isActive = true
            view.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor, constant: 0).isActive = true
        }

        pageControl.numberOfPages = viewModel?.pageCount ?? 0
        scrollViewDidScroll(scrollView)
    }

    func addLegalPage() {
        let view = OnboardingConsentPageView.loadFromNib()
        view.viewModel = viewModel
        stackView.addArrangedSubview(view)
        view.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: 0).isActive = true
        view.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor, constant: 0).isActive = true
    }

    func updateButtonCaption(_ caption: String) {
        button.setAttributedTitle(caption.locaStyled(style: .primaryButton), for: .normal)
    }

    func scrollToPage(_ page: Int) {
        let width = Int(scrollView.frame.size.width)
        let target = CGPoint(x: width * page, y: 0)
        scrollView.setContentOffset(target, animated: true)
    }

    @IBAction func buttonPressed(_ sender: Any) {
        viewModel?.buttonPressed()
    }
    
    private func setAccessibilityOrder() {
        pageControl.isAccessibilityElement = false

        var accessViews = [UIView]()
        
        stackView.subviews.forEach({
            if let view = $0 as? OnboardingPageView {
                if let text = view.headingLabel.text, !text.isEmpty {
                    accessViews.append(view.headingLabel)
                }

                if let text = view.textLabel.text, !text.isEmpty {
                    accessViews.append(view.textLabel)
                }

                if let text = view.textLabel2.text, !text.isEmpty {
                    accessViews.append(view.textLabel2)
                }

                if let text = view.button.titleLabel?.text, !text.isEmpty {
                    accessViews.append(view.button)
                }
                
                if let text = view.textView.text, !text.isEmpty {
                    accessViews.append(view.textView)
                }
                
                if view.imageView.image != nil {
                    accessViews.append(view.imageView)
                }
                
            } else if let view = $0 as? OnboardingConsentPageView {
                if let text = view.headingLabel.text, !text.isEmpty {
                    accessViews.append(view.headingLabel)
                }

                if let text = view.textLabel.text, !text.isEmpty {
                    accessViews.append(view.textLabel)
                }
                
                if let text = view.checkboxLabelView.label.text, !text.isEmpty {
                    accessViews.append(view.checkboxLabelView)
                }

                if let text = view.textLabel2.text, !text.isEmpty {
                    accessViews.append(view.textLabel2)
                }
                
                if let text = view.textView.text, !text.isEmpty {
                    accessViews.append(view.textView)
                }
            }
        })
        
        accessViews.append(button)

        stackView.accessibilityElements = accessViews
    }
}

extension OnboardingViewController: UIScrollViewDelegate {
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
