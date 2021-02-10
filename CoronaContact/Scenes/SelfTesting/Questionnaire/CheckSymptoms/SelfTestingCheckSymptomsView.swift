//
//  SelfTestingCheckSymptomsView.swift
//  CoronaContact
//

import M13Checkbox
import Resolver
import Reusable
import SwiftRichString
import UIKit

final class SelfTestingCheckSymptomsView: UIView, NibLoadable {
    @IBOutlet var questionTitle: TransHeadingLabel!
    @IBOutlet var sourceButton: TransButton!
    @IBOutlet var questionText: TransHeadingLabel!
    @IBOutlet var answersStackView: UIStackView!
    @IBOutlet weak var questionTitleView: UIView!
    var handleAnswer: ((Answer) -> Void)?
    var sourceButtonPressed: (() -> Void)?
    var question: Question?
    
    var shouldShowSourceButton: Bool? {
        didSet {
            configureView()
        }
    }

    private var answerViews = [AnswerView]()

    private func configureView() {
        guard let question = question, let shouldShowSourceButton = shouldShowSourceButton else {
            return
        }

        questionTitle.styledText = question.title
        questionText.styledText = question.questionText
        
        sourceButton.isHidden = !shouldShowSourceButton

        addAnswers(question.answers)
                
        questionTitleView.accessibilityElements = [questionTitle, questionText]
        questionTitleView.accessibilityLabel = questionTitle.text! + " " + questionText.text!
        questionTitleView.isAccessibilityElement = true
        questionTitleView.accessibilityTraits = .header
    }

    private func addAnswers(_ answers: [Answer]) {
        answersStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        answerViews.removeAll()

        answers.forEach(addAnswer)

        let spacerView = UIView()
        answersStackView.addArrangedSubview(spacerView)
    }

    private func addAnswer(_ answer: Answer) {
        let answerView = AnswerView.loadFromNib()
        answerView.configure(with: answer)
        answerView.handleTap = { [weak self] in
            self?.handleAnswer?(answer)
            self?.deselectAllAnswers()

            answerView.setSelectedState(true)
        }

        answerViews.append(answerView)
        answersStackView.addArrangedSubview(answerView)
    }

    private func deselectAllAnswers() {
        answerViews.forEach { $0.setSelectedState(false, animated: false) }
    }
    
    @IBAction func sourceButtonPressed(_ sender: Any) {
        self.sourceButtonPressed?()
    }
}
