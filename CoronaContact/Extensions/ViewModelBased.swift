//
//  ViewModelBased.swift
//  CoronaContact
//

import UIKit
import Reusable

protocol ViewModel: class {
}

protocol ViewModelBased: class {
    associatedtype ViewModel
    var viewModel: ViewModel { get set }
}

extension ViewModelBased where Self: StoryboardBased & UIViewController {
    static func instantiate(with viewModel: ViewModel) -> Self {
        let viewController = Self.instantiate()
        viewController.viewModel = viewModel
        return viewController
    }
}
