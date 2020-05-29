//
//  LaunchScreenViewController.swift
//  CoronaContact
//

import Reusable
import UIKit

final class LaunchScreenViewController: UIViewController, StoryboardBased {
    @IBOutlet private var launchScreenView: LaunchScreenView!

    func fadeOut(withDuration duration: TimeInterval) {
        launchScreenView.startFadeOutAnimation(withDuration: duration)
    }
}
