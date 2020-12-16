//
//  OnboardingViewModel.swift
//  CoronaContact
//

import Resolver
import UIKit

struct OnboardingPage {
    let headline: String
    let text: String
    let text2: String?
    let image: String?
    let textViewText: String?
    let imageAccessibiltyText: String?
    let buttonText: String?
    let buttonIcon: String?
    let buttonHandler: (() -> Void)?
    
    init(headline: String, text: String, text2: String?, image: String? = nil, imageAccessibiltyText: String? = nil, textViewText: String? = nil, buttonText: String? = nil, buttonIcon: String? = nil, buttonHandler: (() -> Void)? = nil) {
        self.headline = headline
        self.text = text
        self.text2 = text2
        self.image = image
        self.imageAccessibiltyText = imageAccessibiltyText
        self.buttonText = buttonText
        self.buttonIcon = buttonIcon
        self.buttonHandler = buttonHandler
        self.textViewText = textViewText
    }
}

class OnboardingViewModel: ViewModel {
    @Injected private var localStorage: LocalStorage

    public var agreementToDataPrivacy = false {
        didSet {
            if agreementToDataPrivacy {
                localStorage.agreedToDataPrivacyAt = Date()
                viewController?.isButtonEnabled = true
            } else {
                localStorage.agreedToDataPrivacyAt = nil
                viewController?.isButtonEnabled = false
            }
        }
    }

    enum Context {
        case regular
        case legal

        var pageCount: Int {
            switch self {
            case .regular:
                return 5
            case .legal:
                return 6
            }
        }
    }

    weak var coordinator: OnboardingCoordinator?
    weak var viewController: OnboardingViewController?

    var pages: [OnboardingPage] = []
    var currentPage = -1
    var currentContext: Context
    var pageCount: Int {
        currentContext.pageCount
    }

    init(with coordinator: OnboardingCoordinator, context: Context = .regular) {
        self.coordinator = coordinator
        currentContext = context

        pages = [
            OnboardingPage(
                headline: "onboarding_headline_1".localized,
                text: "onboarding_copy_1".localized,
                text2: nil,
                image: "OnboardingPage1",
                imageAccessibiltyText: "onboarding_copy_1_img".localized
            ),
            OnboardingPage(
                headline: "onboarding_headline_2".localized,
                text: "onboarding_copy_2".localized,
                text2: nil,
                image: "OnboardingPage2",
                imageAccessibiltyText: "onboarding_copy_2_img".localized,
                buttonText: "automatic_handshake_information_hint".localized,
                buttonIcon: "exclamationMark",
                buttonHandler: { [weak self] in
                    self?.howDoesItWork()
                }
            ),
            OnboardingPage(
                headline: "onboarding_headline_3".localized,
                text: "onboarding_copy_3".localized,
                text2: nil,
                image: "OnboardingPage3",
                imageAccessibiltyText: "onboarding_copy_3_img".localized
            ),
            OnboardingPage(
                headline: "onboarding_headline_4".localized,
                text: "onboarding_copy_4".localized,
                text2: nil,
                image: "OnboardingPage4",
                imageAccessibiltyText: "onboarding_copy_4_img".localized
            ),
            OnboardingPage(
                headline: "onboarding_headline_5".localized,
                text: "onboarding_copy_5_1".localized,
                text2: nil,
                textViewText: "onboarding_copy_5_2".localized
            ),
        ]
    }

    func setupViewController(_ viewController: OnboardingViewController) {
        viewController.setOnboardingPages(pages)
        if currentContext == .legal {
            viewController.addLegalPage()
        }
    }

    func newPageShown(_ page: Int) {
        currentPage = page
        if page < pageCount - 1 {
            viewController?.updateButtonCaption("onboarding_next_button".localized)
            if currentContext == .legal {
                viewController?.isButtonEnabled = true
            }
        } else {
            viewController?.updateButtonCaption("onboarding_finish_buton".localized)
            if currentContext == .legal {
                viewController?.isButtonEnabled = agreementToDataPrivacy
            }
        }
    }

    func buttonPressed() {
        if currentPage < pageCount - 1 {
            viewController?.scrollToPage(currentPage + 1)
            return
        }
        if currentContext == .legal, agreementToDataPrivacy {
            completedLegalOnboarding()
            return
        }
        if currentContext == .regular {
            coordinator?.finish(animated: true)
        }
    }

    func completedLegalOnboarding() {
        localStorage.hasSeenOnboarding = true
        coordinator?.finish(animated: true)
    }

    private func consent() {
        coordinator?.consent()
    }
    
    private func howDoesItWork() {
        coordinator?.howDoesItWork()
    }

    private func termsOfUse() {
        coordinator?.termsOfUse()
    }

    func dataPrivacy() {
        coordinator?.dataPrivacy()
    }

    func viewClosed() {
        coordinator?.finish()
    }
}
