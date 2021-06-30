//
//  BasePickerView.swift
//  CoronaContact
//

import UIKit

enum PickerViewSource {
    case dates(dates: [Date] = [])
    case diaryEntry(entries: [DiaryEntry] = DiaryEntry.allCases)
    case state(states: [Bundesland] = [])
}

class BasePickerView: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {
    
    private let pickerWidth: CGFloat = 366
    private let pickerHeight: CGFloat = 56
    
    final var selectedDate: Date?
    final var selectedDiaryEntry: DiaryEntry?
    final var selectedState: Bundesland = .österreich
    
    var pickerViewData: PickerViewSource? {
        didSet {
            setupPickerView()
        }
    }
    
    init() {
        super.init(frame: .zero)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupPickerView() {
        delegate = self
        dataSource = self
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let dataSource = pickerViewData else { return 0 }
        
        switch dataSource {
        case let .dates(dates):
            return dates.count
        case let .diaryEntry(entries):
            return entries.count
        case .state(states: let states):
            return states.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return pickerHeight
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return pickerWidth
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        guard let dataSource = pickerViewData else { return }
        
        switch dataSource {
        case let .dates(dates):
            selectedDate = dates[row]
        case let .diaryEntry(entries):
            selectedDiaryEntry = entries[row]
        case .state(states: let states):
            selectedState = states[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        guard let dataSource = pickerViewData else { return nil }
        
        //  "safe" is an operator that does array bounds checking and returns nil if the index is invalid
        // Hiding the iOS 14* gray background view
        pickerView.subviews[safe:1]?.backgroundColor = UIColor.clear
        
        var visibleString = ""
        
        switch dataSource {
        case let .dates(dates):
            visibleString = Calendar.current.isDateInToday(dates[row]) ? "general_today".localized : dates[row].longDayShortMonthLongYear
        case let .diaryEntry(entries):
            visibleString = entries[row].translatedName
        case .state(states: let states):
            visibleString = states[row].localized
        }
        
        let attributedString = NSMutableAttributedString(string: visibleString)
        
        let range = NSRange(location: 0, length: visibleString.count)
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.ccRedButton, range: range)
        
        attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 20, weight: .bold), range: range)

        return attributedString
    }
}
