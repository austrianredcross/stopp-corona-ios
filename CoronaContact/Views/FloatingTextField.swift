//
//  FloatingTextField.swift
//  CoronaContact
//

import UIKit

class FloatingTextField: UITextField, ValidateableInputType {
    enum ErrorState {
        case none
        case message(String)
    }

    // MARK: Internal Properties

    weak var customDelegate: InputElementDelegate?

    @IBInspectable var desiredHeight: CGFloat = 58.0
    var insets: UIEdgeInsets = .zero
    var labelInsets: UIEdgeInsets = .zero {
        didSet {
            label.insets = labelInsets
        }
    }

    @IBInspectable var labelText: String = "" {
        didSet {
            label?.text = labelText
        }
    }

    var labelFont: UIFont? {
        didSet {
            guard let font = labelFont else {
                return
            }

            label.font = font
        }
    }

    override var placeholder: String? {
        get {
            attributedPlaceholder?.string
        }
        set {
            configurePlaceholder(newValue, font: placeholderFont)
        }
    }

    var placeholderFont: UIFont? {
        didSet {
            guard let font = placeholderFont else {
                return
            }

            configurePlaceholder(placeholder, font: font)
        }
    }

    var errorFont: UIFont? {
        didSet {
            guard let font = errorFont else {
                return
            }

            errorLabel.font = font
        }
    }

    var error: ErrorState = .none {
        didSet {
            updateErrorRepresentation()
        }
    }

    var errorIsVisible: Bool {
        guard let errorLabel = errorLabel, !errorLabel.isHidden else {
            return false
        }

        return true
    }

    var errorLabelTopPadding: CGFloat = 8
    var isValidationEnabled = true

    // MARK: - Private Properties

    private let validation = InputValidation()
    private(set) var isValid = true

    private var label: PaddingLabel!
    private var labelTopConstraint: NSLayoutConstraint!
    private var labelLeadingConstraint: NSLayoutConstraint!
    private var borderView: UIView!
    private var errorLabel: UILabel!
    private var errorLabelHeight: CGFloat {
        guard errorIsVisible else {
            return 0
        }

        return errorLabel.frame.height
    }

    private var calculatedErrorLabelTopPadding: CGFloat {
        guard errorIsVisible else {
            return 0
        }

        return errorLabelTopPadding
    }

    private var calculatedInsets: UIEdgeInsets {
        let topInset: CGFloat

        if case .none = error {
            topInset = insets.top
        } else {
            topInset = insets.top - errorLabelHeight - errorLabelTopPadding
        }

        return UIEdgeInsets(top: topInset, left: insets.left, bottom: insets.bottom, right: insets.right)
    }

    private var calculatedBorderWidth: CGFloat {
        isEditing ? 2.0 : 1.0
    }

    override var intrinsicContentSize: CGSize {
        CGSize(
            width: UIView.noIntrinsicMetric,
            height: desiredHeight + errorLabelHeight + calculatedErrorLabelTopPadding
        )
    }

    // MARK: - ValidateableInputType

    var isOptional: Bool = false
    var inputValue: String {
        text ?? ""
    }

    var inputType: ValidateableInputContent = .text {
        didSet {
            switch inputType {
            case .email:
                keyboardType = .emailAddress
                autocapitalizationType = .none

            case .numbers:
                keyboardType = .numberPad
                configureToolBar()

            case .phone:
                keyboardType = .phonePad
                configureToolBar()

            default:
                keyboardType = .asciiCapable
                autocapitalizationType = .sentences
            }
        }
    }

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()

        configureView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        labelTopConstraint?.constant = -(label.frame.height / 2)
        labelLeadingConstraint?.constant = insets.left
        updateErrorRepresentation()
    }

    override func becomeFirstResponder() -> Bool {
        representCurrentState()
        customDelegate?.inputElementBecameActive(self)
        return super.becomeFirstResponder()
    }

    // MARK: - Setup

    func configureView() {
        isValid = validate() == nil
        borderStyle = .none
        addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        addTarget(self, action: #selector(textFieldFinished), for: .editingDidEndOnExit)

        configurePlaceholder()
        configureBorderView()
        configureLabel()
        configureErrorLabel()
    }

    private func configurePlaceholder(_ placeholder: String? = nil, font: UIFont? = nil) {
        guard let placeholder = placeholder else {
            return
        }

        var attributes = [NSAttributedString.Key: Any]()

        if let font = font {
            attributes[.font] = font
        }

        attributedPlaceholder = NSAttributedString(string: placeholder, attributes: attributes)
    }

    private func configureBorderView() {
        borderView = UIView()
        borderView.layer.cornerRadius = 8
        borderView.layer.borderWidth = 1.0
        borderView.layer.borderColor = UIColor.ccBorder.cgColor
        borderView.translatesAutoresizingMaskIntoConstraints = false
        borderView.isUserInteractionEnabled = false

        addSubview(borderView)

        NSLayoutConstraint.activate([
            borderView.leadingAnchor.constraint(equalTo: leadingAnchor),
            borderView.topAnchor.constraint(equalTo: topAnchor),
            borderView.trailingAnchor.constraint(equalTo: trailingAnchor),
            borderView.heightAnchor.constraint(equalToConstant: desiredHeight),
        ])
    }

    private func configureLabel() {
        label = PaddingLabel(frame: textRect(forBounds: bounds))
        label.text = labelText
        label.insets = labelInsets
        label.backgroundColor = UIColor.systemBackground
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = false
        addSubview(label)
        bringSubviewToFront(label)

        labelTopConstraint = label.topAnchor.constraint(equalTo: topAnchor, constant: -(label.frame.height / 2))
        labelLeadingConstraint = label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: insets.left)

        NSLayoutConstraint.activate([
            labelTopConstraint,
            labelLeadingConstraint,
        ])
    }

    private func configureErrorLabel() {
        errorLabel = UILabel()
        errorLabel.textColor = .red
        errorLabel.numberOfLines = 0
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.isHidden = true

        borderView.addSubview(errorLabel)

        NSLayoutConstraint.activate([
            errorLabel.leadingAnchor.constraint(equalTo: borderView.leadingAnchor),
            errorLabel.topAnchor.constraint(equalTo: borderView.bottomAnchor, constant: errorLabelTopPadding),
            errorLabel.trailingAnchor.constraint(equalTo: borderView.trailingAnchor),
        ])
    }

    private func representCurrentState() {
        borderView.layer.borderWidth = calculatedBorderWidth
    }

    private func configureToolBar() {
        let toolbar: UIToolbar = UIToolbar()
        toolbar.items = [UIBarButtonItem(title: "accessibility_keyboard_confirm_title".localized, style: .done, target: self, action: #selector(hideKeyboard)) ]
        toolbar.sizeToFit()
        self.inputAccessoryView = toolbar
    }
    
    @objc func hideKeyboard() {
        shouldResignFirstResponder()
    }
    // MARK: - Actions

    @objc private func textFieldDidChange() {
        customDelegate?.inputElementDidChange(self)
    }

    @objc private func textFieldFinished() {
        representCurrentState()
        customDelegate?.inputElementDidFinish(self)
    }

    // MARK: - Error handling

    private func updateErrorRepresentation() {
        defer {
            invalidateIntrinsicContentSize()
        }

        guard case let .message(error) = error else {
            removeError()
            return
        }

        showError(message: error)
    }

    private func showError(message: String) {
        errorLabel?.text = message
        errorLabel?.isHidden = false
        borderView?.layer.borderColor = UIColor.red.cgColor
        borderView?.layer.borderWidth = 2
    }

    private func removeError() {
        errorLabel?.isHidden = true
        borderView?.layer.borderColor = UIColor.ccBorder.cgColor
        borderView?.layer.borderWidth = calculatedBorderWidth
    }

    // MARK: - Text placement

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        bounds
            .inset(by: calculatedInsets)
            .insetBy(dx: labelInsets.left, dy: 0)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        textRect(forBounds: bounds)
    }
}

// MARK: - Validation

extension FloatingTextField {
    @discardableResult
    func forceValidation() -> Bool {
        guard isValidationEnabled else { return true }

        let errorMessage: String?
        defer {
            if let errorMessage = errorMessage {
                error = .message(errorMessage)
            } else {
                error = .none
            }
        }

        if let validationError = validate() {
            errorMessage = {
                switch validationError {
                case .empty:
                    accessibilityLabel = "general_validation_required".localized
                    UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: self)
                    return "general_validation_required".localized
                case let .invalid(reason):
                    accessibilityLabel = reason
                    UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: self)
                    return reason
                }
            }()
            isValid = false
        } else {
            isValid = true
            accessibilityLabel = labelText
            errorMessage = nil
        }

        return isValid
    }

    private func validate() -> ValidationError? {
        validation.validate(self)
    }
}

// MARK: - InputElementType

extension FloatingTextField: InputElementType {
    public func shouldBecomeFirstResponder() {
        _ = becomeFirstResponder()
    }

    public func shouldResignFirstResponder() {
        resignFirstResponder()
    }
}
