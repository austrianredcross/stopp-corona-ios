//
// DebugViewController.swift
// CoronaContact
//

import UIKit
import Reusable
import SwiftRichString
import Resolver

class DebugViewController: UIViewController, StoryboardBased, ViewModelBased, Reusable {
    @Injected private var crypto: CryptoService
    @Injected private var p2pkit: P2PKitService

    var viewModel: DebugViewModel? {
        didSet {
            viewModel?.viewController = self
        }
    }

    @IBOutlet weak var p2pID: UILabel!
    @IBOutlet weak var p2pStack: UIStackView!

    func updateP2PStack(events: [P2PKitEvent]) {
        for view in p2pStack.arrangedSubviews {
            view.removeFromSuperview()
        }

        let mono = Style {
            $0.font = SystemFonts.AmericanTypewriter_Bold.font(size: 14)
            $0.alignment = .center
        }
        let now = Date()
        let intervalStart = now.addingTimeInterval(-p2pkit.detectionInterval)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss"

        events.reversed().forEach { event in

            let label = UILabel()
            label.adjustsFontSizeToFitWidth = true
            label.attributedText = "\(crypto.getPublicKeyPrefix(publicKey: event.pubKey)) Signal:\(event.signalStrength)"
                    .set(style: mono)
            p2pStack.addArrangedSubview(label)
            let label2 = UILabel()
            label2.adjustsFontSizeToFitWidth = true
            label2.textAlignment = .center

            let score = p2pkit.calculateScoreFor(event, intervalStart, now)
            var end = "n.a."
            if let endDate = event.end { end = dateFormatter.string(from: endDate) }
            label2.text = "\(dateFormatter.string(from: event.start)) - \(end) Score: \(String(format: "%.3f", score))"
            p2pStack.addArrangedSubview(label2)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.viewWillAppear()

    }

    @IBAction func close(_ sender: Any) {
        viewModel?.close()
    }

    @IBAction func shareLogButtonTapped(_ sender: Any) {
        viewModel?.shareLog()
    }

    @IBAction func resetLogButtonTapped(_ sender: Any) {
        viewModel?.resetLog()
    }

    @IBAction func addHandshakeAction(_ sender: Any) {
        viewModel?.addHandShakes()
    }

    @IBAction func addRedInfectionMessage(_ sender: Any) {
        viewModel?.addRedInfectionMessage()
    }

    @IBAction func addYellowInfectionMessage(_ sender: Any) {
        viewModel?.addYellowInfectionMessage()
    }

    @IBAction func scheduleTestNotifications(_ sender: Any) {
        viewModel?.scheduleTestNotifications()
    }

    @IBAction func attestSickness(_ sender: Any) {
        viewModel?.attestSickness()
    }

    @IBAction func isUnderSelfMonitoringTapped(_ sender: Any) {
        UserDefaults.standard.isUnderSelfMonitoring = true
        UserDefaults.standard.performedSelfTestAt = Date()
        NotificationCenter.default.post(name: .DatabaseSicknessUpdated, object: nil)
    }

    @IBAction func isProbablySickTapped(_ sender: Any) {
        UserDefaults.standard.isProbablySick = true
        UserDefaults.standard.isProbablySickAt = Date()
        NotificationCenter.default.post(name: .DatabaseSicknessUpdated, object: nil)
    }
}
