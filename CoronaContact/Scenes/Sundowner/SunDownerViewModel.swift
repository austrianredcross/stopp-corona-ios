//
//  SundownerViewModel.swift
//  CoronaContact
//

import Foundation
import Resolver

struct SunDownerPage {
    let headline: String
    let text: String
    let image: String?
    let imageAccessibiltyText: String?
    let buttonText: String?
    
    init(headline: String, text: String, image: String? = nil, imageAccessibiltyText: String? = nil, buttonText: String? = nil) {
        self.headline = headline
        self.text = text
        self.image = image
        self.imageAccessibiltyText = imageAccessibiltyText
        self.buttonText = buttonText
    }
}

class SunDownerViewModel: ViewModel {
    @Injected private var localStorage: LocalStorage

    weak var coordinator: SunDownerCoordinator?
    weak var viewController: SunDownerViewController?

    var pages: [SunDownerPage] = []
    var currentPage = -1

    var pageCount: Int {
        pages.count
    }

    init(with coordinator: SunDownerCoordinator) {
        self.coordinator = coordinator

        pages = [
            SunDownerPage(
                headline: "sunDowner_first_page_title".localized,
                text: "sunDowner_first_page_content".localized,
                image: "SunDowner1",
                imageAccessibiltyText: "sunDowner1_img".localized
            ),
            SunDownerPage(
                headline: String(format: "sunDowner_second_page_title".localized, Date().sundDownerDate.shortDayShortMonthLongYear),
                text: String(format: "sunDowner_second_page_content".localized, Date().sundDownerDate.shortDayShortMonthLongYear, Date().sundDownerDate.shortDayShortMonthLongYear)
            ),
            SunDownerPage(
                headline: "sunDowner_third_page_title".localized,
                text: "sunDowner_third_page_content".localized,
                image: "LaunchScreenBottom",
                imageAccessibiltyText: "sunDowner2_img".localized,
                buttonText: "sunDowner_third_page_newsletter_button".localized
            ),
        ]
    }
    
    func showNewsletter() {
        coordinator?.showNewsletter()
    }

    func setupViewController(_ viewController: SunDownerViewController) {
        viewController.setPages(pages)
    }

    func newPageShown(_ page: Int) {
        currentPage = page
        if page < pageCount - 1 {
            viewController?.updateButtonCaption("onboarding_next_button".localized)
        } else {
            viewController?.updateButtonCaption("sunDowner_third_page_button".localized)
        }
    }

    func buttonPressed() {
        if currentPage < pageCount - 1 {
            viewController?.scrollToPage(currentPage + 1)
            return
        }
        
        localStorage.hasBeenVisibleSunDowner = true
        self.coordinator?.finish()
    }
}
