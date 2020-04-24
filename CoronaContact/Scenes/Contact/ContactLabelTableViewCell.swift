//
//  ContactLabelTabelViewCell.swift
//  CoronaContact
//

import UIKit
import Reusable

class ContactLabelTableViewCell: AutoMarginTableViewCell, NibReusable {
    @IBOutlet weak var label: TransLabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
}
