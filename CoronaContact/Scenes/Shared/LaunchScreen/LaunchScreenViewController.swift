//
//  LaunchScreenViewController.swift
//  CoronaContact
//

import UIKit
import Reusable

final class LaunchScreenViewController: UIViewController, StoryboardBased {

    @IBOutlet private weak var launchScreenView: LaunchScreenView!

    func fadeOut(withDuration duration: TimeInterval) {
        launchScreenView.startFadeOutAnimation(withDuration: duration)
    }
}
