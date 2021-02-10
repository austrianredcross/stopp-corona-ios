//
//  IconLabelView.swift
//  CoronaContact
//

import UIKit
import Reusable

class IconLabelView: UIView, NibLoadable {
    
    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var infoLabel: TransLabel!
        
    func configureView(icon: String, text: String) {
    
        iconImageView.image = UIImage(named: icon)
        infoLabel.text = text
    }
}
