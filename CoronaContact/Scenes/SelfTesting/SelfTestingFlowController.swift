//
//  SelfTestingFlowController.swift
//  CoronaContact
//

import Foundation
import Resolver

class SelfTestingFlowController {
    var questionaire: Questionnaire?
    var answers = [Int: Answer]()

    init(config: ConfigurationService) {
        let localLanguage = Language(rawValue: "current_language".localized)
        questionaire = config.currentConfig.diagnosticQuestionnaire[localLanguage ?? Language.english] ?? nil
    }

    func question(at index: Int) -> Question? {
        questionaire?.questions[safe: index]
    }

    func nextStep(at index: Int) -> Decision? {
        answers[index]?.decision
    }

    func selectAnswer(_ answer: Answer, forQuestionAt index: Int) {
        answers[index] = answer
    }
    
    func sourcButtonPressed() {
        ExternalWebsite.symptomsSource.openInSafariVC()
    }
}
