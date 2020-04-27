//
//  ActivityPresentable.swift
//  CoronaContact
//

import UIKit

/**
 Show and hide activity overlays as embedded views.
 
 - note: Use `ActivityPresentableFullscreen` if you want the overlay to be full-screen. The overlay
 will be added above navigation and tab bars.
*/
protocol ActivityPresentable: ActivityPresentableType {}
protocol ActivityPresentableFullscreen: ActivityPresentable, ActivityPresentableFullscreenType {}

extension ActivityPresentable where Self: UIViewController {

    private var hostView: UIView? {
        if activityPresentationStyle == .overFullscreen, let keyWindow = UIApplication.shared.keyWindow {
            return keyWindow
        } else {
            return view
        }
    }

    private var activityView: UIView {
        guard let view = hostView?.subviews.first(where: { $0 is ActivityView }) else {
           return ActivityView(configuration: configuration)
        }

        return view
    }

    func showActivity() {
        guard let hostView = hostView else { return }

        embed(activityView, in: hostView)
    }

    func hideActivity() {
        removeEmbedded(activityView)
    }

    private func embed(_ activity: UIView, in view: UIView) {
        if activity.superview == view { return }
        if activity.superview != nil {
            activity.removeFromSuperview()
        }

        activity.alpha = 0
        view.embedSubview(activity)

        UIView.animate(withDuration: 0.2) {
            activity.alpha = 1
        }
    }

    private func removeEmbedded(_ activity: UIView) {
        UIView.animate(withDuration: 0.2, animations: {
            activity.alpha = 0
        }, completion: { _ in
            activity.removeFromSuperview()
        })
    }
}
