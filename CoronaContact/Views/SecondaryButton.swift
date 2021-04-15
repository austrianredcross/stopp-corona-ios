//
//  SecondaryButton.swift
//  CoronaContact
//

import UIKit

class SecondaryButton: TransButton {
    override func updateTranslation() {
        if let transKeyNormal = transKeyNormal {
            DispatchQueue.main.async { [weak self] in
                self?.setAttributedTitle(transKeyNormal.locaStyled(style: .secondaryButton), for: .normal)
            }
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        configureView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        configureView()
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        configureView()
    }

    private func configureView() {
        backgroundColor = UIColor.systemBackground
        layer.cornerRadius = 8
        layer.borderColor = UIColor.ccRedButton.cgColor
        layer.borderWidth = 1
        layer.masksToBounds = true
        heightAnchor.constraint(equalToConstant: 56).isActive = true
    }
}
