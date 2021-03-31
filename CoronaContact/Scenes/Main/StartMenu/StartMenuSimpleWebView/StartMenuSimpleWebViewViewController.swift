//
//  StartMenuSimpleWebViewViewController.swift
//  CoronaContact
//

import Reusable
import UIKit
import WebKit

final class StartMenuSimpleWebViewViewController: UIViewController, StoryboardBased, ViewModelBased {
    var viewModel: StartMenuSimpleWebViewViewModel?
    var navigationBarHidden = false

    @IBOutlet var webView: WKWebView!
    @IBOutlet var closeButton: UIBarButtonItem!

    var isDarkMode = false
    let log = ContextLogger(context: .default)

    var htmlStyle: String {
        return isDarkMode ? "DarkStyle" : "LightStyle"
    }
    
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
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if self.traitCollection.userInterfaceStyle == .dark {
            isDarkMode = true
        } else {
            isDarkMode = false
        }
        setupUI()
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
        
        if self.traitCollection.userInterfaceStyle == .dark {
            isDarkMode = true
        } else {
            isDarkMode = false
        }
        setupUI()
    }

    private func setupUI() {
        guard let website = viewModel?.website else {
            return
        }

        title = website.title

        let url = website.url
        webView.loadFileURL(url, allowingReadAccessTo: url)
        webView.isOpaque = false
        webView.backgroundColor = .systemBackground
        
        let strCssHead = """
            <head>\
            <link rel="stylesheet" type="text/css" href="\(htmlStyle).css">\
            </head>
            """
        
        do {
            let contents = try String(contentsOf: url)
            if let stylePath = Bundle.main.path(forResource: htmlStyle, ofType: "css") {
                let styleURL = URL(fileURLWithPath: stylePath)
                webView.loadHTMLString(
                    "\(strCssHead)\(contents)",
                    baseURL: styleURL)
            }
        } catch {
            log.error("web content from URL: \(url) could not be loaded error: \(error)")
        }
    }

    @IBAction func closeButtonTapped(_ sender: Any) {
        viewModel?.viewClosed()
    }
}
