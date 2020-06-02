//
//  InputValidation.swift
//  CoronaContact
//

import Foundation

protocol InputElementDelegate: AnyObject {
    func inputElementBecameActive(_ element: InputElementType)
    func inputElementDidChange(_ element: InputElementType)
    func inputElementDidFinish(_ element: InputElementType)
}

extension InputElementDelegate {
    func inputElementBecameActive(_ element: InputElementType) {}
    func inputElementDidChange(_ element: InputElementType) {}
    func inputElementDidFinish(_ element: InputElementType) {}
}

protocol InputElementType: AnyObject {
    var customDelegate: InputElementDelegate? { get set }
    var isValid: Bool { get }
    var isOptional: Bool { get }
    @discardableResult func forceValidation() -> Bool
    func shouldBecomeFirstResponder()
    func shouldResignFirstResponder()
}

enum ValidationError: Error {
    case empty
    case invalid(reason: String)
}

protocol ValidateableInputType {
    var isOptional: Bool { get }
    var inputValue: String { get }
    var inputType: ValidateableInputContent { get }
}

enum ValidateableInputContent {
    case text
    case numbers
    case phone(errorMessage: String)
    case email
}

protocol ValidationRuleType {
    func validate(_ value: String) -> ValidationError?
}

class InputValidation {
    func validate(_ input: ValidateableInputType) -> ValidationError? {
        if input.isOptional, input.inputValue.isEmpty {
            return nil
        }
        guard !input.inputValue.isEmpty else {
            return .empty
        }

        var rules: [ValidationRuleType] = []
        switch input.inputType {
        case let .phone(errorMessage):
            rules.append(PhoneNumberRule(ruleMessage: errorMessage))
        default:
            break
        }

        for rule in rules {
            if let error = rule.validate(input.inputValue) {
                return error
            }
        }

        return nil
    }
}

class RegexRule: ValidationRuleType {
    let ruleMessage: String
    let expression: String

    init(expression: String, ruleMessage: String) {
        self.ruleMessage = ruleMessage
        self.expression = expression
    }

    func validate(_ value: String) -> ValidationError? {
        guard value.range(of: expression, options: String.CompareOptions.regularExpression) != nil else {
            return ValidationError.invalid(reason: ruleMessage)
        }

        return nil
    }
}

final class ContainsNumbersRule: RegexRule {
    init() {
        super.init(expression: ".*\\d.*", ruleMessage: "")
    }
}

final class PhoneNumberRule: ValidationRuleType {
    let ruleMessage: String

    init(ruleMessage: String) {
        self.ruleMessage = ruleMessage
    }

    func validate(_ value: String) -> ValidationError? {
        let set = CharacterSet.decimalDigits.union(.whitespaces).union(CharacterSet(charactersIn: "+"))

        guard set.isSuperset(of: CharacterSet(charactersIn: value)),
            value.first == "+" else {
            return ValidationError.invalid(reason: ruleMessage)
        }

        guard ContainsNumbersRule().validate(value) == nil else {
            return ValidationError.invalid(reason: ruleMessage)
        }

        return nil
    }
}
