//
//  ContactTableViewCell.swift
//  CoronaContact
//

import UIKit

import Reusable

class ContactTableViewCell: AutoMarginTableViewCell, NibReusable {
    @IBOutlet weak var idLabel: TransLabel!
    @IBOutlet weak var saveLabel: TransLabel!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var checkboxView: CheckboxView!

    var isChecked: Bool {
        checkboxView.checkState == .checked
    }

    var isEnabled: Bool {
        checkboxView.isEnabled
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        configureView()
    }

    func configureView() {
        selectionStyle = .none
        saveLabel.isHidden = true
        iconView.isHidden = true
    }

    func configureCell(withText text: String) {
        idLabel.styledText = text
    }

    func configureCell(_ contact: RemoteContact) {
        let isContactSaved = contact.saved

        idLabel.styledText = String(format: "handshake_code_%@", contact.name).localized
        saveLabel.isHidden = !isContactSaved
        iconView.isHidden = !isContactSaved
        checkboxView.isEnabled = !isContactSaved
        if isContactSaved && checkboxView.checkState == .unchecked {
            checkboxView.toggleCheckState()
        }

        if contact.selected {
            checkboxView.setCheckState(.checked, animated: true)
        } else if !isContactSaved {
            checkboxView.setCheckState(.unchecked, animated: true)
        }
    }
}
