//
//  SicknessCertificatePersonalDataViewController.swift
//  CoronaContact
//

import Reusable
import UIKit
import Resolver

final class SicknessCertificatePersonalDataViewController: UIViewController,
    StoryboardBased, ViewModelBased, ActivityModalPresentable, FlashableScrollIndicators
{
    @Injected private var localStorage: LocalStorage
    private var keyboardAdjustingBehavior: KeyboardAdjustingBehavior?
    private var elements: [InputElementType] = []

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var mobileNumberTextField: StandardTextField!
    @IBOutlet var personalDataDescriptionLabel: TransLabel!
    @IBOutlet weak var textfield: UITextField!

    let datePicker = DatePickerView()

    var viewModel: SicknessCertificatePersonalDataViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupViewModel()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        flashScrollIndicators()
    }

    private func setupUI() {
        let behavior = KeyboardAdjustingBehavior(scrollView: scrollView)
        behavior.keyboardPadding = 40
        keyboardAdjustingBehavior = behavior

        title = "sickness_certificate_personal_data_title".localized
        
        personalDataDescriptionLabel.styledText = viewModel?.personalDataDescription

        mobileNumberTextField.labelText = "sickness_certificate_personal_data_mobile_number_label".localized
        mobileNumberTextField.inputType = .phone(errorMessage: "sickness_certificate_personal_data_phone_field_invalid".localized)
        mobileNumberTextField.placeholder = "sickness_certificate_personal_data_mobile_number_placeholder".localized
        mobileNumberTextField.accessibilityLabel = "sickness_certificate_personal_data_mobile_number_label".localized

        elements.append(mobileNumberTextField)
        showDatePicker()
    }

    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        if parent == nil {
            viewModel?.viewClosed()
        }
    }

    private func setupViewModel() {
        viewModel?.composePersonalData = { [weak self] in
            guard let self = self else {
                return nil
            }

            let mobileNumber = (self.mobileNumberTextField.text ?? "").replacingOccurrences(of: " ", with: "")

            return PersonalData(mobileNumber: mobileNumber)
        }
    }
    
    func showDatePicker() {
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "accessibility_keyboard_confirm_title".localized, style: .plain, target: self, action: #selector(confirmButtonTapped))
        
        toolbar.setItems([doneButton], animated: false)
        
        textfield.inputAccessoryView = toolbar
        textfield.inputView = datePicker
        
        if localStorage.hasSymptomsOrPositiveAttestAt != nil {
            let date = localStorage.hasSymptomsOrPositiveAttestAt!
            personalDataDescriptionLabel.styledText = viewModel?.personalDataDescription
            textfield.text = Calendar.current.isDateInToday(date) ? "general_today".localized : date.longDayShortMonthLongYear
        } else {
            confirmButtonTapped()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
    }
    
    @objc func keyboardDidShow(notification: NSNotification) {
        UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: datePicker)
    }
    
    @objc func confirmButtonTapped() {
        let date = datePicker.getSelectedDate ?? Date()
        
        localStorage.hasSymptomsOrPositiveAttestAt = date
        
        personalDataDescriptionLabel.styledText = viewModel?.personalDataDescription

        textfield.text = Calendar.current.isDateInToday(date) ? "general_today".localized : date.longDayShortMonthLongYear
        
        self.view.endEditing(true)
    }

    @IBAction func nextButtonTapped(_ sender: Any) {
        elements.forEach { $0.forceValidation() }

        let isValid = !elements.map(\.isValid).contains(false)

        guard isValid else {
            return
        }

        showActivity()
        viewModel?.goToNext(completion: { [weak self] in
            self?.hideActivity()
        })
    }
}
