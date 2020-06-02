//
//  Coordinator+ShareSheet.swift
//  CoronaContact
//

import UIKit

protocol ShareSheetPresentable {
    associatedtype ViewController: UIViewController

    var rootViewController: ViewController { get }
}

extension ShareSheetPresentable where Self: Coordinator {
    func presentActivity(activityItems: [Any], applicationActivities: [UIActivity]? = nil) {
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        rootViewController.present(activityViewController, animated: true, completion: nil)
    }

    func presentShareAppActivity() {
        guard let appStoreAppUrl = UIApplication.appStoreAppUrl else {
            return
        }

        let item = String(format: "share_app_content".localized, appStoreAppUrl.absoluteString)

        presentActivity(activityItems: [item])
    }
}
