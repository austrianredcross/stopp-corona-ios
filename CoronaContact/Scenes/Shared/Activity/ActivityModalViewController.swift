//
//  ActivityModalViewController.swift
//  CoronaContact
//

import UIKit

class ActivityModalViewController: UIViewController {
    let activityView = ActivityView()
    private let configuration: ActivityConfiguration

    init(configuration: ActivityConfiguration) {
        self.configuration = configuration

        super.init(nibName: nil, bundle: nil)

        switch configuration.presentationStyle {
        case .overCurrentContext:
            modalPresentationStyle = .overCurrentContext
        case .overFullscreen:
            modalPresentationStyle = .overFullScreen
        }
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        super.loadView()
        view = UIView()

        let activityView = ActivityView(configuration: configuration)
        view.embedSubview(activityView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        activityView.activity.startAnimating()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        activityView.activity.stopAnimating()
    }
}
