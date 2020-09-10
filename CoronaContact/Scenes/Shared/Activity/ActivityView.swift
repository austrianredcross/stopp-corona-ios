//
//  ActivityView.swift
//  CoronaContact
//

import UIKit

class ActivityView: UIView {
    let activity = UIActivityIndicatorView(frame: .zero)
    private let label = UILabel(frame: .zero)
    private let configuration: ActivityConfiguration

    private static let defaultConfiguration = ActivityConfiguration(style: .white, presentationStyle: .overFullscreen)

    init(configuration: ActivityConfiguration = defaultConfiguration) {
        self.configuration = configuration

        super.init(frame: .zero)

        configureView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureView() {
        switch configuration.style {
        case .white:
            backgroundColor = UIColor.white.withAlphaComponent(0.9)
            label.textColor = .ccBlack
        }

        activity.style = .large
        activity.color = .ccRouge
        activity.startAnimating()

        addSubview(activity)
        activity.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            activity.centerXAnchor.constraint(equalTo: centerXAnchor),
            activity.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])

        label.text = configuration.text
        label.numberOfLines = 0
        label.textAlignment = .center

        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: activity.bottomAnchor, constant: 16),
            label.safeAreaLayoutGuide.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: label.safeAreaLayoutGuide.trailingAnchor, constant: 16),
        ])
    }
}
