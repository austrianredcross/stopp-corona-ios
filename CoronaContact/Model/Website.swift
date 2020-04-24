//
//  Website.swift
//  CoronaContact
//

import UIKit

enum Website: String {
    case imprint = "imprint"
    case privacy = "privacy"
    case termsOfUse = "terms-of-use"
    case privacyAndTermsOfUse = "privacy-and-terms-of-use"

    private var localisedFileName: String {
        return Language.current.rawValue + "." + rawValue
    }

    var url: URL {
        Bundle.main.url(forResource: localisedFileName, withExtension: "html")!
    }

    var title: String {
        switch self {
        case .imprint:
            return "start_menu_item_2_3_imprint".localized
        case .privacyAndTermsOfUse:
            return "start_menu_item_2_2_data_privacy".localized
        case .privacy:
            return "onboarding_data_privacy_headline".localized
        case .termsOfUse:
            return "onboarding_terms_of_use_headline".localized
        }
    }
}

enum ExternalWebsite: String {
    case faq = "start_menu_item_1_2_faq_link_link_target"
    case homepage = "start_menu_item_1_3_red_cross_link_link_target"

    var url: URL? {
        URL(string: rawValue.localized) ?? URL(string: "https://roteskreuz.at")
    }
}

extension ExternalWebsite {

    func openInSafariVC(from viewController: UIViewController? = nil) {
        guard let url = url else {
            return
        }

        UIApplication.shared.openURLinSafariVC(url, from: viewController)
    }
}
