//
//  ActivityPresentableType.swift
//  CoronaContact
//

import UIKit

/**
 Abstract protocol to show and hide activity overlays.

 Do not add this protocol directly to a view controller. Instead, use either `ActivityModalPresentable`
 to present an activity overlay modally as a view controller or `ActivityPresentable` to show the
 activity as an embedded view. Both concrete protocols have a full-screen variant if you want the
 activity overlay to be full-screen.

 By default the overlay will be shown over the current context.

 */
protocol ActivityPresentableType: AnyObject {
    /// Default implementation available
    var configuration: ActivityConfiguration { get }

    /// Text that is displayed below the activity indicator
    var activityText: String { get }

    /**
     Defines the background color of the overlay

     Default value is `.white`.
     */
    var activityStyle: ActivityStyle { get }

    /**
     Defines the presentation style of the overlay

     - The default value for `ActivityPresentableType` is `.overCurrentContext`.
     - The default value for `ActivityPresentableFullscreenType` is `.overFullscreen`.
     */
    var activityPresentationStyle: ActivityPresentationStyle { get }

    /// Default implementation available on `UIViewController`
    func showActivity()

    /// Default implementation available on `UIViewController`
    func hideActivity()
}

extension ActivityPresentableType {
    var configuration: ActivityConfiguration {
        .init(text: activityText, style: activityStyle, presentationStyle: activityPresentationStyle)
    }

    var activityText: String {
        "general_loading".localized
    }
}

extension ActivityPresentableType where Self: UIViewController {
    var activityPresentationStyle: ActivityPresentationStyle {
        .overCurrentContext
    }

    var activityStyle: ActivityStyle {
        .white
    }
}

/**
 Abstract protocol to show and hide activity overlays.

 Do not add this protocol directly to a view controller. Instead, use either `ActivityModalPresentableFullscreen`
 to present an activity overlay modally as a view controller or `ActivityPresentableFullscreen` to show the
 activity as an embedded view.

 The overlay will be shown full-screen.

 - note: Use `ActivityPresentableType` if you want the overlay to be shown over the current context only.

 - note: There is also a bindable sink available for `rx.isActivityVisible`.
 */
protocol ActivityPresentableFullscreenType: ActivityPresentableType {}

extension ActivityPresentableFullscreenType {
    var activityPresentationStyle: ActivityPresentationStyle {
        .overFullscreen
    }
}
