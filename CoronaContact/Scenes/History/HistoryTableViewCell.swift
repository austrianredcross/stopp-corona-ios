//
//  ContactTableViewCell.swift
//  CoronaContact
//

import UIKit

import Reusable

class HistoryTableViewCell: AutoMarginTableViewCell, NibReusable {
    @IBOutlet weak var dateLabel: TransLabel!
    @IBOutlet weak var timeLabel: TransLabel!
    @IBOutlet weak var modeLabel: TransLabel!
    let formatter = DateFormatter()

    func setUpCell(_ history: History) {
        modeLabel.styledText = history.autoDiscovered ? "history_mode_automatic".localized : nil
        dateLabel.styledText = history.dateString
        timeLabel.styledText = history.timeRangeString
    }

    override func awakeFromNib() {
        selectionStyle = .none
        formatter.dateStyle = .short
        super.awakeFromNib()
    }
}
