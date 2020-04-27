//
//  SelfTestingCheckSymptomsViewController.swift
//  CoronaContact
//

import UIKit
import Reusable

final class SelfTestingCheckSymptomsViewController: UIViewController, StoryboardBased, ViewModelBased {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var button: UIButton!

    var viewModel: SelfTestingCheckSymptomsViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        if parent == nil {
            viewModel?.viewClosed()
        }
    }

    private func setupUI() {
        view.clipsToBounds = true
        title = "self_testing_check_symptoms_title".localized
        button.isEnabled = false

        setupQuestion()
    }

    func setupQuestion() {
        let questionView = SelfTestingCheckSymptomsView.loadFromNib()

        stackView.addArrangedSubview(questionView)
        questionView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: 0).isActive = true
        questionView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor, constant: 0).isActive = true
        questionView.handleAnswer = { [weak self] answer in
            self?.selectedAnswer(answer)
        }
        questionView.question = viewModel?.question
    }

    private func selectedAnswer(_ answer: Answer) {
        guard let viewModel = viewModel else {
            return
        }

        viewModel.selectAnswer(answer)
        button.isEnabled = viewModel.isButtonEnabled
    }

    @IBAction func nextButtonTapped(_ sender: Any) {
        viewModel?.goToNext()
    }
}
