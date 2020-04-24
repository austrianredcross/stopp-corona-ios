//
//  StartMenuSimpleWebViewViewController.swift
//  CoronaContact
//

import UIKit
import Reusable
import WebKit

final class StartMenuSimpleWebViewViewController: UIViewController, StoryboardBased, ViewModelBased {
    var viewModel: StartMenuSimpleWebViewViewModel?
    var navigationBarHidden = false

    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var closeButton: UIBarButtonItem!

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if navigationController?.navigationBar.isHidden == true {
                navigationBarHidden = false
                navigationController?.setNavigationBarHidden(false, animated: true)
        }
        if presentingViewController == nil {
            navigationItem.rightBarButtonItems = []
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if navigationBarHidden {
            navigationController?.setNavigationBarHidden(true, animated: true)
        }

    }

    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        if parent == nil {
            viewModel?.viewClosed()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    private func setupUI() {
        guard let website = viewModel?.website else {
            return
        }

        title = website.title

        let url = website.url
        webView.loadFileURL(url, allowingReadAccessTo: url)
        let request = URLRequest(url: url)
        webView.load(request)
    }

    @IBAction func closeButtonTapped(_ sender: Any) {
        viewModel?.viewClosed()
    }
}
