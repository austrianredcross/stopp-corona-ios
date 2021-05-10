//
//  DiaryDetailEntryCell.swift
//  CoronaContact
//

import UIKit
import Resolver
import Reusable

class DiaryDetailEntryCell: UITableViewCell, ViewModelBased {
        
    @IBOutlet var diaryEntryIconImageView: UIImageView!
    @IBOutlet var diaryEntryNameLabel: UILabel!
    @IBOutlet var diaryInformationStackView: UIStackView!
    @IBOutlet var cellBackgroundView: SelectedRoundCornersView!
    @IBOutlet var deleteButton: UIButton!
    
    @IBOutlet weak var titleEntryToTitleInformationConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleEntryToBottomConstraint: NSLayoutConstraint!

    var viewModel: DiaryDetailEntryCellViewModel? {
        didSet {
            setupUI()
        }
    }

    func setupUI() {
        
        guard let viewModel = viewModel else { return }
        diaryInformationStackView.subviews.forEach({ $0.removeFromSuperview() })

        titleEntryToBottomConstraint.priority = viewModel.diaryEntryInformationLabels.isEmpty ? .required : .defaultLow
        
        titleEntryToTitleInformationConstraint.priority = !viewModel.diaryEntryInformationLabels.isEmpty ? .required : .defaultLow
        
        diaryEntryIconImageView.image = viewModel.diaryEntryIconImage
        diaryEntryNameLabel.text = viewModel.diaryEntryTitle
        viewModel.diaryEntryInformationLabels.forEach({ diaryInformationStackView.addArrangedSubview($0) })
        cellBackgroundView.roundCorners(corners: .allCorners, radius: 5)
        addShadow(ofColor: .black, radius: 3, offset: CGSize(width: 0, height: 1), opacity: 0.5)
        
        let tintedImage = deleteButton.imageView?.image?.withRenderingMode(.alwaysTemplate)
        deleteButton.imageView?.tintColor = .ccRedButton
        deleteButton.imageView?.contentMode = .scaleAspectFit
        deleteButton.setImage(tintedImage, for: .normal)
        deleteButton.setImage(tintedImage, for: .disabled)
        deleteButton.setImage(tintedImage, for: .highlighted)
                
        // Separate the words with a comma so Voice over will make a pause between each word
        var accessibilityLabelText = viewModel.diaryEntryIconImage!.accessibilityLabel! + "," + diaryEntryNameLabel.text!
        viewModel.diaryEntryInformationLabels.compactMap({ $0.text }).forEach({
            accessibilityLabelText += ", \($0)"
        })
        
        cellBackgroundView.accessibilityLabel = accessibilityLabelText
        cellBackgroundView.isAccessibilityElement = true
        
        cellBackgroundView.accessibilityCustomActions = [ UIAccessibilityCustomAction(name: "diary_delete_delete_button".localized, target: self, selector: #selector(self.deleteEntry)) ]

    }
    
    @objc func deleteEntry() {
        guard let viewModel = viewModel else { return }
        
        viewModel.deleteEntryButtonPressed()
    }
    
    @IBAction func deleteEntryButtonPressed(_ sender: Any) {
        guard let viewModel = viewModel else { return }
        
        viewModel.deleteEntryButtonPressed()
    }
}
