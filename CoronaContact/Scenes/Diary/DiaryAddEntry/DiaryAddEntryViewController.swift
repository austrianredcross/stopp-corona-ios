//
//  DiaryAddEntryViewController.swift
//  CoronaContact
//

import UIKit
import Reusable

class DiaryAddEntryViewController: UIViewController, StoryboardBased, ViewModelBased {
    
    @IBOutlet var diaryEntryTextField: UITextField!
    @IBOutlet var nonOptionalTextField: StandardTextField!
    @IBOutlet var diaryAddTitleLabel: TransHeadingLabel!
    
    @IBOutlet var personWrapperView: UIStackView!
    @IBOutlet var personNoticeTextView: UITextView!
    @IBOutlet var locationWrapperView: UIStackView!
    @IBOutlet var locationDayPeriodSelectorView: DiaryLocationDayPeriodSelector!
    
    @IBOutlet var publicTransportWrapperView: UIStackView!
    @IBOutlet var publicTransportDepartureTextField: StandardTextField!
    @IBOutlet var publicTransportDestinationTextField: StandardTextField!
    @IBOutlet var publicTransportDepartureTimeTextField: StandardTextField!
    
    @IBOutlet var eventWrapperView: UIStackView!
    @IBOutlet var eventArrivalTimeTextField: StandardTextField!
    @IBOutlet var eventDepartureTimeTextField: StandardTextField!

    @IBOutlet var closeButton: UIButton!
    @IBOutlet var closeButtonView: SelectedRoundCornersView!
    let diaryEntryPicker = DiaryEntryPicker()
    
    let timePicker: UIDatePicker = {
        let timePicker = UIDatePicker()
        timePicker.preferredDatePickerStyle = .wheels
        timePicker.datePickerMode = .time
        timePicker.minuteInterval = 5
        let fiveMinuteInterval = 300.0
        
        timePicker.date = Date(timeIntervalSinceReferenceDate: (Date().timeIntervalSinceReferenceDate / fiveMinuteInterval).rounded(.toNearestOrAwayFromZero) * fiveMinuteInterval)
        
        return timePicker
    }()
    
    var viewModel: DiaryAddEntryViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUI()
    }
    
    let doneButton = UIBarButtonItem(title: "accessibility_keyboard_confirm_title".localized, style: .plain, target: self, action: #selector(dismissKeyboard))

    lazy var toolbar: UIToolbar = {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
  
        toolBar.setItems([doneButton], animated: false)
        return toolBar
    }()
    
    func setupUI() {
        configureDiaryEntryPicker()
        configureDatePicker()
        configureButton()
        
        configurePersonTextView()
        configureTransportView()
        configureEventView()
        
        // add the toolbar with the Submit button to the TextFields
        nonOptionalTextField.inputAccessoryView = toolbar
        publicTransportDepartureTextField.inputAccessoryView = toolbar
        publicTransportDestinationTextField.inputAccessoryView = toolbar
        publicTransportDepartureTimeTextField.inputAccessoryView = toolbar
        eventArrivalTimeTextField.inputAccessoryView = toolbar
        eventDepartureTimeTextField.inputAccessoryView = toolbar
        
        diaryAddTitleLabel.styledText = "diary_add_title".localized

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)

        updateUI()
    }
    
    func configureTransportView() {
        publicTransportDepartureTextField.placeholder = "diary_add_public_transport_place_departure".localized
        publicTransportDestinationTextField.placeholder = "diary_add_public_transport_place_destination".localized
        publicTransportDepartureTimeTextField.placeholder = "diary_add_public_transport_departure_time".localized
    }
    
    func configurePersonTextView() {
        personNoticeTextView.text = "diary_add_person_notes".localized
        personNoticeTextView.textColor = UIColor.lightGray
        personNoticeTextView.delegate = self
        personNoticeTextView.inputAccessoryView = toolbar
    }
    
    func configureButton() {
        closeButtonView.roundCorners(corners: .allCorners, radius: closeButtonView.frame.height / 2)
        let tintedImage = closeButton.imageView?.image?.withRenderingMode(.alwaysTemplate)
        closeButton.imageView?.tintColor = .systemBackground
        closeButton.imageView?.contentMode = .scaleAspectFit
        closeButton.setImage(tintedImage, for: .normal)
        closeButton.setImage(tintedImage, for: .disabled)
        closeButton.setImage(tintedImage, for: .highlighted)
    }
    
    func configureDiaryEntryPicker() {

        diaryEntryTextField.inputAccessoryView = toolbar
        diaryEntryTextField.inputView = diaryEntryPicker
        diaryEntryTextField.addTarget(self, action: #selector(diaryEntryTextFieldIsSelected), for: .editingDidBegin)

        let diaryEntry = diaryEntryPicker.choosenDiaryEntry ?? .person
        diaryEntryTextField.styledText = diaryEntry.translatedName
        viewModel?.currentSelectedDiaryEntry = diaryEntry
    }
    
    func configureDatePicker() {
        publicTransportDepartureTimeTextField.inputAccessoryView = toolbar
        publicTransportDepartureTimeTextField.inputView = timePicker
        publicTransportDepartureTimeTextField.addTarget(self, action: #selector(publicTransportDepartureTimeTextFieldIsSelected), for: .editingDidBegin)
    }
    
    func configureEventView() {
        eventArrivalTimeTextField.inputAccessoryView = toolbar
        eventArrivalTimeTextField.inputView = timePicker
        eventArrivalTimeTextField.placeholder = "diary_add_event_arrival_time".localized
        eventArrivalTimeTextField.addTarget(self, action: #selector(eventArrivalTimeTextFieldIsSelected), for: .editingDidBegin)

        eventDepartureTimeTextField.inputAccessoryView = toolbar
        eventDepartureTimeTextField.inputView = timePicker
        eventDepartureTimeTextField.placeholder = "diary_add_event_departure_time".localized
        
        eventDepartureTimeTextField.addTarget(self, action: #selector(eventDepartureTimeTextFieldIsSelected), for: .editingDidBegin)
    }
    
    @objc func eventDepartureTimeTextFieldIsSelected(textField: UITextField) {
        doneButton.action = #selector(confirmEventDepartureDatePickerButtonTapped)
        toolbar.setItems([doneButton], animated: false)
    }
    
    @objc func eventArrivalTimeTextFieldIsSelected(textField: UITextField) {
        doneButton.action = #selector(confirmEventArrivalDatePickerButtonTapped)
        toolbar.setItems([doneButton], animated: false)
    }
    
    @objc func publicTransportDepartureTimeTextFieldIsSelected(textField: UITextField) {
        doneButton.action = #selector(confirmDatePickerButtonTapped)
        toolbar.setItems([doneButton], animated: false)
    }
    
    @objc func diaryEntryTextFieldIsSelected(textField: UITextField) {
        doneButton.action = #selector(confirmDiaryEntryButtonTapped)
        toolbar.setItems([doneButton], animated: false)
    }
    
    @objc func confirmEventArrivalDatePickerButtonTapped() {
        eventArrivalTimeTextField.text = "\(timePicker.date.dayTime)) \("diary_hour".localized)"
        
        dismissKeyboard()
    }
    
    @objc func confirmEventDepartureDatePickerButtonTapped() {
        eventDepartureTimeTextField.text = "\(timePicker.date.dayTime)) \("diary_hour".localized)"
        
        dismissKeyboard()
    }
    
    @objc func keyboardDidShow(notification: NSNotification) {
        UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: diaryEntryPicker)
    }
    
    @objc func confirmDiaryEntryButtonTapped() {
        let diaryEntry = diaryEntryPicker.choosenDiaryEntry ?? .person
        diaryEntryTextField.styledText = diaryEntry.translatedName
        viewModel?.currentSelectedDiaryEntry = diaryEntry
        updateUI()

        _ = nonOptionalTextField.becomeFirstResponder()

        dismissKeyboard()
    }
    
    @objc func confirmDatePickerButtonTapped() {
        publicTransportDepartureTimeTextField.text = "\(timePicker.date.dayTime)) \("diary_hour".localized)"

        dismissKeyboard()
    }
    
    @objc func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    func updateUI() {
        
        guard let viewModel = viewModel else { return }
        
        switch viewModel.currentSelectedDiaryEntry {
        case .location:
            locationWrapperView.isHidden = false
            personWrapperView.isHidden = true
            publicTransportWrapperView.isHidden = true
            eventWrapperView.isHidden = true
            
            nonOptionalTextField.placeholder = "diary_add_person_mandatory_field".localized
            
        case .person:
            locationWrapperView.isHidden = true
            personWrapperView.isHidden = false
            publicTransportWrapperView.isHidden = true
            eventWrapperView.isHidden = true
            
            nonOptionalTextField.placeholder = "diary_add_location_mandatory_field".localized

        case .publicTransport:
            locationWrapperView.isHidden = true
            personWrapperView.isHidden = true
            publicTransportWrapperView.isHidden = false
            eventWrapperView.isHidden = true
            
            nonOptionalTextField.placeholder = "diary_add_public_transport_mandatory_field".localized

        case .event:
            locationWrapperView.isHidden = true
            personWrapperView.isHidden = true
            publicTransportWrapperView.isHidden = true
            eventWrapperView.isHidden = false
            
            nonOptionalTextField.placeholder = "diary_add_event_mandatory_field".localized
        }
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        viewModel?.closeButtonPressed()
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {

        nonOptionalTextField.forceValidation()
        viewModel?.saveButtonPressed()
    }
}

extension DiaryAddEntryViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText = textView.text ?? ""
        
        guard let stringRange = Range(range, in: currentText) else { return false }
        
        let updatedText = currentText.replacingCharacters(in: stringRange, with: text)
        
        return updatedText.count <= 200
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            configurePersonTextView()
        }
    }
}
