//
//  StatisticsCollectionViewCell.swift
//  CoronaContact
//

import UIKit

class StatisticsCollectionViewCell: UICollectionViewCell {
        
    @IBOutlet var firstContainerView: UIView!
    @IBOutlet var firstTitle: UILabel!
    @IBOutlet var firstImageContainerView: UIView!
    @IBOutlet var firstImageView: UIImageView!
    @IBOutlet var firstContent: UILabel!
    @IBOutlet var firstSubContent: UILabel!
    
    @IBOutlet var secondContainerView: UIView!
    @IBOutlet var secondTitle: UILabel!
    @IBOutlet var secondImageContainerView: UIView!
    @IBOutlet var secondImageView: UIImageView!
    @IBOutlet var secondContent: UILabel!
    @IBOutlet var secondSubContent: UILabel!

    static var identifier: String {
        return String(describing: self)
    }
    
    var statisticsInfo: StatisticsInfo? {
        didSet {
            self.updateUI()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        firstTitle.isAccessibilityElement = false
        firstContent.isAccessibilityElement = false
        firstSubContent.isAccessibilityElement = false
        firstImageView.isAccessibilityElement = false
        firstContainerView.isAccessibilityElement = true

        secondTitle.isAccessibilityElement = false
        secondContent.isAccessibilityElement = false
        secondSubContent.isAccessibilityElement = false
        secondImageView.isAccessibilityElement = false
        secondContainerView.isAccessibilityElement = true

        firstContainerView.setAccessibilityElements(with: [firstTitle, firstImageView, firstContent, firstSubContent])
        secondContainerView.setAccessibilityElements(with: [secondTitle, secondContent, secondSubContent, secondImageView])
    }
    
    func updateUI() {
        guard let statisticsInfo = self.statisticsInfo else {
            resetLabels()
            return
        }
            firstTitle.styledText = statisticsInfo.topInfo.title
            firstContent.styledText = statisticsInfo.topInfo.currentValue.asFormattedString
            firstSubContent.styledText = statisticsInfo.topInfo.delta.asFormattedStringWithSignPrefix
            
            firstImageContainerView.isHidden = !statisticsInfo.showPrefixImage
            firstImageView.image = statisticsInfo.loadSignPrefixImage(from: statisticsInfo.topInfo.delta)
            
            secondTitle.styledText = statisticsInfo.bottomInfo.title
            secondContent.styledText = statisticsInfo.bottomInfo.currentValue.asFormattedString
            secondSubContent.styledText = statisticsInfo.bottomInfo.delta.asFormattedStringWithSignPrefix
            secondImageView.image = statisticsInfo.loadSignPrefixImage(from: statisticsInfo.bottomInfo.delta)
            
            secondImageContainerView.isHidden = !statisticsInfo.showPrefixImage

            firstContainerView.setAccessibilityLabel(with: [statisticsInfo.topInfo.title, statisticsInfo.loadSignPrefixText(from: statisticsInfo.topInfo.delta), statisticsInfo.topInfo.currentValue.asFormattedStringWithSignPrefix, statisticsInfo.topInfo.delta.asFormattedStringWithSignPrefix])
                
            secondContainerView.setAccessibilityLabel(with: [statisticsInfo.bottomInfo.title, statisticsInfo.loadSignPrefixText(from: statisticsInfo.bottomInfo.delta), statisticsInfo.bottomInfo.currentValue.asFormattedStringWithSignPrefix, statisticsInfo.bottomInfo.delta.asFormattedStringWithSignPrefix])
    }
    
    func resetLabels() {
        firstTitle.text = ""
        firstContent.text = ""
        firstSubContent.text = ""
        secondTitle.text = ""
        secondContent.text = ""
        secondSubContent.text = ""
    }
}
