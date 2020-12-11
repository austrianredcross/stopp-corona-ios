//
//  SelfTestingPersonalDataViewController.swift
//  CoronaContact
//

import Reusable
import UIKit

final class SelfTestingPersonalDataViewController: UIViewController,
    StoryboardBased, ViewModelBased, ActivityModalPresentable, FlashableScrollIndicators
{
    private var keyboardAdjustingBehavior: KeyboardAdjustingBehavior?
    private var elements: [InputElementType] = []

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var mobileNumberTextField: StandardTextField!

    var viewModel: SelfTestingPersonalDataViewModel?

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

        title = "self_testing_personal_data_title".localized

        mobileNumberTextField.labelText = "self_testing_personal_data_mobile_number_label".localized
        mobileNumberTextField.inputType = .phone(errorMessage: "sickness_certificate_personal_data_phone_field_invalid".localized)
        mobileNumberTextField.placeholder = "self_testing_personal_data_mobile_number_placeholder".localized
        mobileNumberTextField.accessibilityLabel = "self_testing_personal_data_mobile_number_label".localized

        elements.append(mobileNumberTextField)
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
