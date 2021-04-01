//
//  DatePickerView.swift
//  CoronaContact
//

import UIKit

class DatePicker: BasePickerView {
    
    convenience init(daysInPast: Int) {
        self.init()
        pickerViewData = PickerViewSource.dates(dates: Date().getDates(forLastDays: daysInPast))
    }

    var chosenDate: Date? {
        return selectedDate
    }
}
