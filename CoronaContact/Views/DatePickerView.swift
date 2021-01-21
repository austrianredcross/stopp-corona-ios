//
//  DatePickerView.swift
//  CoronaContact
//

import UIKit

class DatePickerView: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {

    private let data = Date().getDates(forLastDays: 5)
    private let pickerWidth: CGFloat = 366
    private let pickerHeight: CGFloat = 56
    private var selectedDate: Date?
    
    public var getSelectedDate: Date? {
        return selectedDate
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupPickerView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupPickerView()
    }
    
    private func setupPickerView() {
        delegate = self
        dataSource = self
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return data.count
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return pickerHeight
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return pickerWidth
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedDate = data[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        //  "safe" is an operator that does array bounds checking and returns nil if the index is invalid
        // Hiding the iOS 14* gray background view
        pickerView.subviews[safe:1]?.backgroundColor = UIColor.clear
        
        let dateString = Calendar.current.isDateInToday(data[row]) ? "general_today".localized : data[row].shortMonthNameString
        
        let attributedString = NSMutableAttributedString(string: dateString)
        
        let range = NSRange(location: 0, length: dateString.count)
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.ccRouge, range: range)
        
        attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 20, weight: .bold), range: range)

        return attributedString
    }
}
