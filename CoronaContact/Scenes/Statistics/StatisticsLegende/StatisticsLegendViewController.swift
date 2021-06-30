//
//  StatisticsLegendViewController.swift
//  CoronaContact
//
import Foundation
import Reusable
import UIKit

final class StatisticsLegendViewController: UIViewController, StoryboardBased, ViewModelBased {
    var viewModel: StatisticsLegendViewModel?
    
    @IBOutlet weak var stackView: UIStackView!

    let heightConstant: CGFloat = 50
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        IncidenceState.allCases.forEach({ oneCase in
            
            let colorImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            colorImageView.translatesAutoresizingMaskIntoConstraints = false
            colorImageView.image = UIImage(color: oneCase.color)
            colorImageView.heightAnchor.constraint(equalToConstant: heightConstant).isActive = true
            colorImageView.widthAnchor.constraint(equalToConstant: heightConstant).isActive = true
            colorImageView.clipsToBounds = true
            colorImageView.layer.cornerRadius = 5
            colorImageView.layer.borderWidth = 1
            colorImageView.layer.borderColor =  oneCase == .zero ? UIColor.black.cgColor : UIColor.white.cgColor
            colorImageView.isAccessibilityElement = true
            
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            label.styleName = "bodySmall"
            label.text = oneCase.localized
            label.translatesAutoresizingMaskIntoConstraints = true
            label.heightAnchor.constraint(equalToConstant: heightConstant).isActive = true
            label.isAccessibilityElement = false

            let caseStackView = UIStackView()
            caseStackView.axis = .horizontal
            caseStackView.distribution = .fillProportionally
            caseStackView.alignment = .leading
            caseStackView.spacing = 16.0

            caseStackView.addArrangedSubview(colorImageView)
            caseStackView.addArrangedSubview(label)

            caseStackView.translatesAutoresizingMaskIntoConstraints = false

            caseStackView.isAccessibilityElement = true
            caseStackView.setAccessibilityElements(with: [colorImageView, label])
            caseStackView.setAccessibilityLabel(with: [oneCase.accessibilityLocalized, oneCase.localized])
            
            stackView.addArrangedSubview(caseStackView)
        })
        
        stackView.sizeToFit()
    }
    
    @IBAction func statisticsLegendClosePressed(_ sender: Any) {
        viewModel?.closeLegend()
    }
}
