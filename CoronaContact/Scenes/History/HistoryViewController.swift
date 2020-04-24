//
//  HistoryViewController.swift
//  CoronaContact
//

import UIKit
import Reusable

class HistoryViewController: UIViewController, StoryboardBased, ViewModelBased, FlashableScrollIndicators {
    var viewModel: HistoryViewModel? {
        didSet {
            viewModel?.viewController = self
        }
    }

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var historyTableView: UITableView?
    @IBOutlet weak var roundedTopRectsView: SelectedRoundCornersView!
    @IBOutlet weak var historyTableViewHeightConstraint: NSLayoutConstraint!

    override func viewDidLoad() {
        super.viewDidLoad()
        roundedTopRectsView.roundCorners(corners: [.topLeft, .topRight], radius: 8)
        historyTableView?.register(cellType: HistoryTableViewCell.self)
    }

    func updateTableView() {
        historyTableView?.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.title = "history_title".localized
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        flashScrollIndicators()
    }
}

extension HistoryViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = .white
        } else {
            cell.backgroundColor = .ccWhite
        }
    }

}

extension HistoryViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let rows = viewModel?.numberOfHistoryElements() ?? 0
        historyTableViewHeightConstraint.constant = (historyTableView?.rowHeight ?? 0) * CGFloat(rows)
        return rows
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let viewModel = viewModel else { return UITableViewCell() }
        let cell = tableView.dequeueReusableCell(for: indexPath) as HistoryTableViewCell
        if let history = viewModel.getHistoryAtIndex(indexPath.row) {
            cell.setUpCell(history)
        }
        return cell
    }

}
