//
//  StatisticsDetailViewController.swift
//  CoronaContact
//

import Foundation
import Reusable
import UIKit

final class StatisticsDetailViewController: UIViewController, StoryboardBased, ViewModelBased {
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var incidenceTableView: UITableView!
    @IBOutlet var textfield: UITextField!
    @IBOutlet var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var statisticsCollectionView: UICollectionView!
    @IBOutlet var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var headlineLabel: TransHeadingLabel!
    @IBOutlet var incidenceComparisonLabel: TransLabel!
    @IBOutlet var descriptionLabel: TransHeadingLabel!
    @IBOutlet var stateImageView: UIImageView!
    @IBOutlet var pageControl: UIPageControl!

    var viewModel: StatisticsDetailViewModel?
    var statePicker = StatePicker(states: Bundesland.getCases)
    let cellMargin: CGFloat = 38
    var collectionViewCalculatedSize: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    @IBAction func statisticsLegendPressed(_ sender: Any) {
        viewModel?.showLegend()
    }
    
    private func setupUI() {
        
        guard let viewModel = viewModel else { return }
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "accessibility_keyboard_confirm_title".localized, style: .plain, target: self, action: #selector(confirmButtonTapped))
        
        toolbar.setItems([doneButton], animated: false)
        
        textfield.inputAccessoryView = toolbar
        textfield.styleName = "bodyLargeBoldRed"
        textfield.inputView = statePicker
        
        title = "covid_statistics_title".localized

        statisticsCollectionView.contentInset = UIEdgeInsets(top: 0, left: cellMargin, bottom: 0, right: 0)
        statisticsCollectionView.dataSource = self
        statisticsCollectionView.delegate = self
        
        incidenceTableView.dataSource = self
        incidenceTableView.delegate = self
        
        viewModel.loadData()
        confirmButtonTapped()

        viewModel.updateView = updateUI

        guard let lastDate = viewModel.agesRepository.lastDate?.shortDayShortMonth,
              let penultimateDate = viewModel.agesRepository.penultimateDate?.shortDayShortMonth else { return }
        
        incidenceComparisonLabel.styledText = String(format: "covid_statistics_incidence_comparison".localized, lastDate, penultimateDate)
        
        pageControl.numberOfPages = viewModel.pageCount
        pageControl.isAccessibilityElement = false

        updateUI()
    }
    
    func updateUI() {
        guard let viewModel = viewModel else { return }

        collectionView.reloadData()
        incidenceTableView.reloadData()
        
        incidenceTableView.layoutIfNeeded()
        collectionView.layoutIfNeeded()

        stateImageView.image = viewModel.drawMap()
        descriptionLabel.styledText = String(format: "covid_statistics_description".localized, viewModel.selectedState.localized)
        
        UIView.animate(withDuration: 0.0, animations: { [weak self] in
            guard let self = self else { return }
            self.tableViewHeightConstraint.constant = self.incidenceTableView.contentSize.height
            
            self.collectionViewHeightConstraint.constant = self.viewModel?.statisticsInfo.count == 0 ? 0 : self.collectionViewCalculatedSize
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    
    @objc func confirmButtonTapped() {
        guard let viewModel = viewModel else { return }
        
        viewModel.selectedState(state: statePicker.selectedState)
        textfield.styledText = statePicker.selectedState.localized
        self.view.endEditing(true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let visibleRect = CGRect(origin: self.collectionView!.contentOffset, size: self.collectionView!.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        if let visibleIndexPath = self.collectionView!.indexPathForItem(at: visiblePoint) {
            self.pageControl.currentPage = visibleIndexPath.row
        }
    }
}

// MARK: - CollectionView Delegate
extension StatisticsDetailViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let viewModel = viewModel else { return 0 }
        return viewModel.statisticsInfo.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StatisticsCollectionViewCell.identifier, for: indexPath) as? StatisticsCollectionViewCell,
              let viewModel = viewModel else { return UICollectionViewCell() }

        cell.statisticsInfo = viewModel.statisticsInfo[indexPath.item]
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let size = CGSize(width: view.frame.width * 0.8, height: 0)
        
        guard let sizingCell = collectionView.dequeueReusableCell(withReuseIdentifier: StatisticsCollectionViewCell.identifier, for: indexPath) as? StatisticsCollectionViewCell,
              let viewModel = viewModel else { return CGSize(width: 0, height: 0) }
        
        sizingCell.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        sizingCell.frame.size = size
        
        sizingCell.statisticsInfo = viewModel.statisticsInfo[indexPath.item]
        // To the get the height from the Cell dynamically
        
        let calculatedSize = sizingCell.contentView.systemLayoutSizeFitting(size, withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.defaultLow)
        
        // Smaller Cells will be automatically centered on the Y axis
        collectionViewCalculatedSize = max(collectionViewCalculatedSize, calculatedSize.height)
        
        return calculatedSize
    }
}

// MARK: - TableView Delegate
extension StatisticsDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let viewModel = viewModel else { return 0 }
        return viewModel.incidences.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: IncidenceTableViewCell.identifier, for: indexPath) as? IncidenceTableViewCell,
              let viewModel = viewModel else { return UITableViewCell() }

        cell.viewModel = viewModel.incidences[indexPath.item]
        return cell
    }
}
