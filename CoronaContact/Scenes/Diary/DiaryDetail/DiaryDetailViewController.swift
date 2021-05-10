//
//  DiaryDetailViewController.swift
//  CoronaContact
//

import Reusable
import UIKit
import CoreData

class DiaryDetailViewController: UIViewController, StoryboardBased, ViewModelBased {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var emptyDataSourceView: UIView!
    
    var viewModel: DiaryDetailViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
 
        NotificationCenter.default.addObserver(self, selector: #selector(contextObjectsDidChange(_:)), name: .NSManagedObjectContextDidSave, object: nil)
    }
    
    @objc func contextObjectsDidChange(_ notification: Notification) {
        
        let possibleKeys = [NSInsertedObjectsKey, NSUpdatedObjectsKey, NSDeletedObjectsKey]
        
        let changedObjects = possibleKeys.reduce(into: []) { $0 += Array(notification.userInfo?[$1] as? Set<NSManagedObject> ?? []) }
        
        if changedObjects.compactMap({ $0.entity.superentity }).contains(where: { $0 == BaseDiaryEntry.entity() }) {
            viewModel?.refreshData()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateUI()
    }
    
    func setupUI() {
        
        title = viewModel?.title
        
        tableView.delegate = self
        tableView.dataSource = self
        
        viewModel?.reloadTableView = { [weak self] in
            self?.tableView.reloadData()
            self?.updateUI()
        }
    }
    
    func updateUI() {
        if let rows = self.viewModel?.numberOfRows, rows > 0 {
            self.emptyDataSourceView.isHidden = true
            self.tableView.isHidden = false
        } else {
            self.emptyDataSourceView.isHidden = false
            self.tableView.isHidden = true
        }
    }
    
    @IBAction func addNewEntryButtonPressed(_ sender: Any) {
        viewModel?.addNewEntryButtonPressed()
    }
}

extension DiaryDetailViewController: UITableViewDelegate { }

extension DiaryDetailViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "diaryDetailEntryCell", for: indexPath) as? DiaryDetailEntryCell,
              let viewModel = viewModel, let diaryEntryInformation = viewModel.getDiaryEntryInformation(for: indexPath.section) else { return UITableViewCell() }
        
        let diaryDetailCellViewModel = DiaryDetailEntryCellViewModel(diaryDetailViewModel: viewModel, diaryEntryInformation: diaryEntryInformation)
        cell.viewModel = diaryDetailCellViewModel
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
                guard let viewModel = viewModel else { return 0 }
        
                return viewModel.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // Set the spacing between sections
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    
    // Make the background color show through
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        
        return headerView
    }
}
