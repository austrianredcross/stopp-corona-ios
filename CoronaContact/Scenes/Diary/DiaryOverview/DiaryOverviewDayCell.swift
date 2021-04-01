//
//  DiaryOverviewDayCell.swift
//  CoronaContact
//

import UIKit

class DiaryOverviewDayCell: UITableViewCell {
    
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var amountView: UIView!
    @IBOutlet var amountLabel: UILabel!
    @IBOutlet var cellBackgroundView: SelectedRoundCornersView!
    var index: Int = 0
    
    var viewModel: DiaryOverviewViewModel? {
        didSet {
            setupUI()
        }
    }

    func setupUI() {
        
        guard let viewModel = viewModel else { return }
        
        dateLabel.text = viewModel.getCellTitle(index: index)
        let amountText = viewModel.getEntryAmountString(index: index)
        amountView.isHidden = amountText == nil
        amountLabel.text = amountText
        cellBackgroundView.roundCorners(corners: .allCorners, radius: 5)
        addShadow(ofColor: .black, radius: 3, offset: CGSize(width: 0, height: 1), opacity: 0.5)
    }
}
