//
//  ViewModelBased.swift
//  CoronaContact
//

import Reusable
import UIKit

protocol ViewModel: AnyObject {}

protocol ViewModelBased: AnyObject {
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
