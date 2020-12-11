//
//  RevokeSicknessPersonalDataViewController.swift
//  CoronaContact
//

import Reusable
import UIKit

final class RevokeSicknessPersonalDataViewController: UIViewController,
    StoryboardBased, ViewModelBased, ActivityModalPresentable, FlashableScrollIndicators
{
    private var keyboardAdjustingBehavior: KeyboardAdjustingBehavior?
    private var elements: [InputElementType] = []

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var mobileNumberTextField: StandardTextField!

    var viewModel: RevokeSicknessPersonalDataViewModel?

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

        title = "revoke_sickness_title".localized

        mobileNumberTextField.labelText = "revocation_personal_data_mobile_number_label".localized
        mobileNumberTextField.inputType = .phone(errorMessage: "revocation_personal_data_phone_field_invalid".localized)
        mobileNumberTextField.placeholder = "revocation_personal_data_mobile_number_placeholder".localized
        mobileNumberTextField.accessibilityValue = "revocation_personal_data_mobile_number_label".localized

        elements.append(mobileNumberTextField)
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
