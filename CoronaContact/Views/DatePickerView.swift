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

class StatePicker: BasePickerView {
    
    convenience init(states: [Bundesland] = Bundesland.allCases) {
        self.init()
        pickerViewData = PickerViewSource.state(states: states)
    }

    var chosenState: Bundesland? {
        return selectedState
    }
}
