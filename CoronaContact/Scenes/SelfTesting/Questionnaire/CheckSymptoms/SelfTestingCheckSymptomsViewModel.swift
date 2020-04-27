//
//  SelfTestingCheckSymptomsViewModel.swift
//  CoronaContact
//

import Foundation
import Resolver

class SelfTestingCheckSymptomsViewModel: ViewModel {

    @Injected private var flowController: SelfTestingFlowController

    weak var coordinator: SelfTestingCheckSymptomsCoordinator?

    private let questionIndex: Int
    var question: Question? {
        flowController.question(at: questionIndex)
    }
    var isButtonEnabled: Bool {
        flowController.answers[questionIndex] != nil
    }

    init(with coordinator: SelfTestingCheckSymptomsCoordinator, questionIndex: Int) {
        self.coordinator = coordinator
        self.questionIndex = questionIndex
    }

    func goToNext() {
        guard let nextStep = flowController.nextStep(at: questionIndex) else {
            return
        }

        coordinator?.nextPage(nextStep, at: questionIndex + 1)
    }

    func selectAnswer(_ answer: Answer) {
        flowController.selectAnswer(answer, forQuestionAt: questionIndex)
    }

    func viewClosed() {
        coordinator?.finish()
    }
}
