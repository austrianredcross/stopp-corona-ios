//
//  SelfTestingCoronaSuspicionViewController.swift
//  CoronaContact
//

import Reusable
import UIKit

final class SelfTestingCoronaSuspicionViewController: UIViewController, StoryboardBased, ViewModelBased, FlashableScrollIndicators {
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet weak var textfield: UITextField!
    
    // Initialize the DatePicker with the last 5 Days.
    let datePicker = DatePicker(daysInPast: 5)

    var viewModel: SelfTestingCoronaSuspicionViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        flashScrollIndicators()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupUI() {
        title = "self_testing_corona_suspicion_title".localized
        showDatePicker()
    }
    
    @IBAction func contactsConfirmedButtonPressed(_ sender: Any) {
        viewModel?.showRevocation()
    }
    
    @IBAction func contactsNotConfirmedButtonPressed(_ sender: Any) {
        viewModel?.showStatusReport()
    }
    
    func showDatePicker() {
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "accessibility_keyboard_confirm_title".localized, style: .plain, target: self, action: #selector(confirmButtonTapped))
        
        toolbar.setItems([doneButton], animated: false)
        
        textfield.inputAccessoryView = toolbar
        textfield.inputView = datePicker
        confirmButtonTapped()

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
    }
    
    @objc func keyboardDidShow(notification: NSNotification) {
        UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: datePicker)
    }
    
    @objc func confirmButtonTapped() {
        let date = datePicker.chosenDate ?? Date()
        viewModel?.saveSelectedReportDate(reportDate: date)
        textfield.text = Calendar.current.isDateInToday(date) ? "general_today".localized : date.longDayShortMonthLongYear
        
        self.view.endEditing(true)
    }
    
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        if parent == nil {
            viewModel?.viewClosed()
        }
    }
}
