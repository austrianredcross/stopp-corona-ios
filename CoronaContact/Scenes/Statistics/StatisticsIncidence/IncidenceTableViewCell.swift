//
//  IncidenceTableViewCell.swift
//  CoronaContact
//

import Foundation
import Reusable
import UIKit

class IncidenceTableViewCell: UITableViewCell, ViewModelBased {
    
    @IBOutlet var incidenceColor: UIView!
    @IBOutlet var incidenceTitle: TransLabel!
    @IBOutlet var incidenceValueIcon: UIImageView!
    @IBOutlet var incidenceValue: TransLabel!
    @IBOutlet var incidenceIncrementValue: TransLabel!
    @IBOutlet var incidenceStackView: UIStackView!
    
    @IBOutlet var contentViewContainer: UIView!
    static var identifier: String {
        return String(describing: self)
    }
    var viewModel: Incidence? {
        didSet {
            configureView()
        }
    }
    
    private func configureView() {
        
        guard let viewModel = viewModel else { return }
        
        incidenceTitle.styleName = StyleNames.body.rawValue
        incidenceValue.styleName = StyleNames.boldCenter.rawValue
        incidenceIncrementValue.styleName = StyleNames.bodyCenter.rawValue
        
        incidenceColor.backgroundColor = viewModel.incidenceState.color
        
        // The State zero will return a white Color so we need to add a border around the View.
        incidenceColor.layer.borderWidth = viewModel.incidenceState == .zero ? 1 : 0
        incidenceColor.layer.borderColor = UIColor.ccBorder.cgColor
        incidenceColor.layer.masksToBounds = true
        incidenceColor.layer.cornerRadius = 8
        
        incidenceTitle.text = viewModel.incidenceTitle
        incidenceValueIcon.image = viewModel.incidenceValueIcon
        incidenceValue.text = viewModel.incidenceValue.asFormattedString
        
        contentViewContainer.isAccessibilityElement = true

        if let localizedValue = viewModel.incidenceIncrementValue?.asFormattedStringWithSignPrefix, !localizedValue.isEmpty {
            incidenceIncrementValue.text = localizedValue
            
            incidenceIncrementValue.isHidden = false
            incidenceStackView.isHidden = false
            
            contentViewContainer.setAccessibilityElements(with: [incidenceColor, incidenceTitle, incidenceValueIcon, incidenceValue, incidenceIncrementValue])
            contentViewContainer.setAccessibilityLabel(with: [viewModel.incidenceState.accessibilityLocalized, viewModel.incidenceTitle,  viewModel.incidenceIncrementValueLocalized, viewModel.incidenceValue.asFormattedString, localizedValue])
            
        } else {
            incidenceIncrementValue.text = ""
            incidenceIncrementValue.isHidden = true
            incidenceStackView.isHidden = true
            
            contentViewContainer.setAccessibilityElements(with: [incidenceColor, incidenceTitle, incidenceValue])
            contentViewContainer.setAccessibilityLabel(with: [viewModel.incidenceState.accessibilityLocalized, viewModel.incidenceTitle, viewModel.incidenceValue.asFormattedString])
        }
    }
}
