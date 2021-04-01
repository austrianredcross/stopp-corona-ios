//
//  DiaryEntryPicker.swift
//  CoronaContact
//

import Foundation

class DiaryEntryPicker: BasePickerView {
    
    override init() {
        super.init()
        pickerViewData = PickerViewSource.diaryEntry()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        pickerViewData = PickerViewSource.diaryEntry()
    }
    
    var choosenDiaryEntry: DiaryEntry? {
        return selectedDiaryEntry
    }
}
