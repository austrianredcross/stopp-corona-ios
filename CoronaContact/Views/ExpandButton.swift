//
//  ExpandButton.swift
//  CoronaContact
//

import UIKit

class ExpandButton: TransButton {
    
    override func updateTranslation() {
        if let transKeyNormal = transKeyNormal?.localized {
            
            let styledText = "\(isCollapsed ? "+ " : "- ") \(transKeyNormal)".locaStyled(style: isCollapsed ? .red : .whiteToBlack)
            
            setAttributedTitle(styledText, for: .normal)
        }
    }
    
    @IBInspectable var isCollapsed: Bool = false {
        didSet {
            guard let title = titleLabel?.text else { return }
            
            if self.isCollapsed {
                backgroundColor = .systemBackground
                accessibilityLabel = "\(title),\("accessibility_is_collapsed".localized)"
            } else {
                backgroundColor = .ccRedButton
                accessibilityLabel = "\(title),\("accessibility_is_expanded".localized)"
            }
            
            updateTranslation()

        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        layer.masksToBounds = true
        heightAnchor.constraint(equalToConstant: defaultHeightConstant).isActive = true
        
        self.roundedCorners(corners: [CACornerMask.layerMinXMinYCorner, CACornerMask.layerMaxXMinYCorner], radius: .small)
        
        updateTranslation()
    }
}
