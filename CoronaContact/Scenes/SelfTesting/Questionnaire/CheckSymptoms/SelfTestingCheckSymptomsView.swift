//
//  SelfTestingCheckSymptomsView.swift
//  CoronaContact
//

import UIKit
import Reusable
import Resolver
import SwiftRichString
import M13Checkbox

final class SelfTestingCheckSymptomsView: UIView, NibLoadable {
    @IBOutlet weak var questionTitle: UILabel!
    @IBOutlet weak var questionText: UILabel!
    @IBOutlet weak var answersStackView: UIStackView!

    var handleAnswer: ((Answer) -> Void)?

    var question: Question? {
        didSet {
            configureView()
        }
    }

    private var answerViews = [AnswerView]()

    private func configureView() {
        guard let question = question else {
            return
        }

        questionTitle.text = question.title
        questionText.text = question.questionText

        addAnswers(question.answers)
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
}
