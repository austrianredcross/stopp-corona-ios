//
//  ActivityModalPresentable.swift
//  CoronaContact
//

import UIKit

private struct AssociatedObjectKeys {
    static var ActivityModalManager = "ActivityModalManager"
}

/**
 Show and hide activity overlays as modal view controllers.
 
 - note: Use `ActivityModalPresentableFullscreen` if you want the overlay to be full-screen.
 */
protocol ActivityModalPresentable: ActivityPresentableType {}
protocol ActivityModalPresentableFullscreen: ActivityModalPresentable, ActivityPresentableFullscreenType {}

extension ActivityModalPresentable where Self: UIViewController {

    func showActivity() {
        activityModalManager.showActivity()
    }

    func hideActivity() {
        activityModalManager.hideActivity()
    }

    private var activityModalManager: ActivityModalStateMachine {
        get {
            let existing = objc_getAssociatedObject(self, &AssociatedObjectKeys.ActivityModalManager)
            guard let existingActivityModalManager = existing as? ActivityModalStateMachine else {
                let new = ActivityModalStateMachine(viewController: self, configuration: configuration)
                self.activityModalManager = new
                return new
            }
            return existingActivityModalManager
        }
        set {
            objc_setAssociatedObject(self, &AssociatedObjectKeys.ActivityModalManager,
                                     newValue,
                                     .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

// MARK: - ActivityModalStateMachine

/**
 A state machine to keep track of the current status of an activity modal
 
 `.show` and `.hide` events are added to a FIFO queue and handled as quickly
 as possible.
 
 Sometimes an event cannot be handled immediately: e.g. a `.hide` event has
 to wait until an activityModal that is currently animating in is fully
 visible.
 
 Sometimes events are discarded without being handled: e.g. a `.hide` event
 is a no-op if there is no activityModal to hide.
 */
private class ActivityModalStateMachine {

    init(viewController: UIViewController,
         configuration: ActivityConfiguration) {
        self.viewController = viewController
        self.configuration = configuration
    }

    func showActivity() {
        eventQueue.append(.show)
    }

    func hideActivity() {
        eventQueue.append(.hide)
    }

    // MARK: Private members
    private weak var viewController: UIViewController?
    private let configuration: ActivityConfiguration

    private enum Event {
        case show, hide
    }

    private enum State {
        case idle,
        animatingIn(ActivityModalViewController),
        visible(ActivityModalViewController),
        animatingOut(ActivityModalViewController)
    }

    private var eventQueue: [Event] = [] {
        didSet {
            DispatchQueue.main.async {
                self.handleNextEvent()
            }
        }
    }
    private var state: State = .idle {
        didSet {
            DispatchQueue.main.async {
                self.handleNextEvent()
            }
        }
    }

    private func handleNextEvent() {
        guard let viewController = viewController else { return }

        switch (state, eventQueue.first) {
        case (.idle, .show?), (.animatingOut, .show?):
            self.eventQueue = Array(eventQueue.dropFirst())
            showModal(on: viewController)

        case (.animatingIn, .show?),
             (.visible, .show?):
            self.eventQueue = Array(eventQueue.dropFirst())

        case (.visible(let modal), .hide?):
            self.eventQueue = Array(eventQueue.dropFirst())
            hide(modal, from: viewController)

        case (.animatingOut, .hide?),
             (.idle, .hide?):
            self.eventQueue = Array(eventQueue.dropFirst())

        case (.animatingIn, .hide?):
            // we have to wait until it's visible before hiding it.
            break

        case (_, nil):
            // no event to handle
            break
        }
    }

    /**
     Checks if the conditions are met to work around an iOS issue that caused
     the modal and its presenting viewController never to be removed from memory
     
     Given a viewController **A** that modally presents viewController **B** under
     the following conditions:
     - **B**`.modalPresentationStyle == .overCurrentContext`
     - **A**`.definesPresentationContext == true`
     
     ...then iOS does not automatically dismiss **B** when **A** is dismissed.
     
     To work around this quirk, we don't present the modal modally in this case. We embed
     it using the UIViewController containment API instead.
     */
    private var needsEmbedding: Bool {
        configuration.presentationStyle == .overCurrentContext
            && viewController?.definesPresentationContext ?? false
    }

    private func showModal(on viewController: UIViewController) {
        let modal = ActivityModalViewController(configuration: configuration)
        state = .animatingIn(modal)

        if needsEmbedding {
            embed(modal, in: viewController) { [weak self] in
                self?.state = .visible(modal)
            }
        } else {
            viewController.present(modal, animated: false) { [weak self] in
                self?.state = .visible(modal)
            }
        }
    }

    private func hide(_ modal: ActivityModalViewController, from viewController: UIViewController) {
        state = .animatingOut(modal)

        if needsEmbedding {
            removeEmbedded(modal, from: viewController) { [weak self] in
                self?.state = .idle
            }
        } else {
            modal.dismiss(animated: false) { [weak self] in
                self?.state = .idle
            }
        }
    }

    private func embed(_ modal: UIViewController, in viewController: UIViewController, completion: @escaping () -> Void) {
        viewController.addChild(modal)
        modal.view.alpha = 0
        viewController.view.addSubview(modal.view)
        modal.view.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            modal.view.topAnchor.constraint(equalTo: viewController.view.topAnchor),
            modal.view.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
            modal.view.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor),
            modal.view.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor)
        ])

        modal.didMove(toParent: viewController)

        UIView.animate(
            withDuration: 0.2,
            animations: {
                modal.view.alpha = 1

            },
            completion: { _ in
                completion()
            }
        )
    }

    private func removeEmbedded(_ modal: UIViewController, from viewController: UIViewController, completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.2, animations: {
            modal.view.alpha = 0
        }, completion: { _ in
            modal.willMove(toParent: nil)
            modal.view.removeFromSuperview()
            modal.removeFromParent()
            completion()
        })
    }
}
