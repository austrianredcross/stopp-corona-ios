//
//  DiaryLocationDayPeriodSelector.swift
//  CoronaContact
//

import UIKit
import Reusable

enum DayPeriod: Int {
    case morning
    case noon
    case afternoon
    case evening
    
    var translated: String {
        switch self {
        case .morning:
            return "diary_add_location_day_period_1".localized
        case .noon:
            return "diary_add_location_day_period_2".localized
        case .afternoon:
            return "diary_add_location_day_period_3".localized
        case .evening:
            return "diary_add_location_day_period_4".localized
        }
    }
}

class DayPeriodGesture: UITapGestureRecognizer {
    var selectedDayPeriod: DayPeriod = .morning
}

class DiaryLocationDayPeriodSelector: UIView, NibOwnerLoadable {
    
    @IBOutlet var morningSelectionView: SelectedRoundCornersView!
    @IBOutlet var noonSelectionView: SelectedRoundCornersView!
    @IBOutlet var afternoonSelectioView: SelectedRoundCornersView!
    @IBOutlet var eveningSelectionView: SelectedRoundCornersView!
    
    @IBOutlet var morningLabel: TransLabel!
    @IBOutlet var noonLabel: TransLabel!
    @IBOutlet var afternoonLabel: TransLabel!
    @IBOutlet var eveningLabel: TransLabel!
    
    var selectedDayPeriod: DayPeriod? {
        didSet {
            updateUI()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        loadNibContent()
        
        morningLabel.accessibilityTraits = .button
        noonLabel.accessibilityTraits = .button
        afternoonLabel.accessibilityTraits = .button
        eveningLabel.accessibilityTraits = .button
                
        setupUI()
    }
    
    private func setupUI() {
        
        let morningTap = DayPeriodGesture(target: self, action: #selector(self.selectionViewTapped(_:)))
        morningTap.selectedDayPeriod = .morning
        morningSelectionView.addGestureRecognizer(morningTap)
        
        let middDayTap = DayPeriodGesture(target: self, action: #selector(self.selectionViewTapped(_:)))
        middDayTap.selectedDayPeriod = .noon
        noonSelectionView.addGestureRecognizer(middDayTap)
        
        let afternoonTap = DayPeriodGesture(target: self, action: #selector(self.selectionViewTapped(_:)))
        afternoonTap.selectedDayPeriod = .afternoon
        afternoonSelectioView.addGestureRecognizer(afternoonTap)
        
        let eveningTap = DayPeriodGesture(target: self, action: #selector(self.selectionViewTapped(_:)))
        eveningTap.selectedDayPeriod = .evening
        eveningSelectionView.addGestureRecognizer(eveningTap)
        
        setSelectionViewToDefault()
    }
    
    private func updateUI() {

        guard let selectedDayPeriod = selectedDayPeriod else { return }
        
        setSelectionViewToDefault()
        
        switch selectedDayPeriod {
        case .morning:
            morningSelectionView.borderColor = .ccDarkBlue
            morningSelectionView.backgroundColor = .ccLightBlue
            morningLabel.accessibilityLabel = morningLabel.text! + "," + "accessibility_active".localized

        case .noon:
            noonSelectionView.borderColor = .ccDarkBlue
            noonSelectionView.backgroundColor = .ccLightBlue
            morningLabel.accessibilityLabel = morningLabel.text! + "," + "accessibility_active".localized

        case .afternoon:
            afternoonSelectioView.borderColor = .ccDarkBlue
            afternoonSelectioView.backgroundColor = .ccLightBlue
            morningLabel.accessibilityLabel = morningLabel.text! + "," + "accessibility_active".localized

        case .evening:
            eveningSelectionView.borderColor = .ccDarkBlue
            eveningSelectionView.backgroundColor = .ccLightBlue
            morningLabel.accessibilityLabel = morningLabel.text! + "," + "accessibility_active".localized
        }
    }
    
    private func setSelectionViewToDefault() {
        
        morningSelectionView.borderColor = .ccBorder
        morningSelectionView.backgroundColor = .ccWhiteGrey
        morningLabel.accessibilityLabel = morningLabel.text! + "," + "accessibility_inactive".localized

        noonSelectionView.borderColor = .ccBorder
        noonSelectionView.backgroundColor = .ccWhiteGrey
        morningLabel.accessibilityLabel = morningLabel.text! + "," + "accessibility_inactive".localized

        afternoonSelectioView.borderColor = .ccBorder
        afternoonSelectioView.backgroundColor = .ccWhiteGrey
        morningLabel.accessibilityLabel = morningLabel.text! + "," + "accessibility_inactive".localized

        eveningSelectionView.borderColor = .ccBorder
        eveningSelectionView.backgroundColor = .ccWhiteGrey
        morningLabel.accessibilityLabel = morningLabel.text! + "," + "accessibility_inactive".localized
    }
    
    @objc private func selectionViewTapped(_ sender: DayPeriodGesture? = nil) {
        guard let gesture = sender else { return }
        selectedDayPeriod = gesture.selectedDayPeriod
    }
}
