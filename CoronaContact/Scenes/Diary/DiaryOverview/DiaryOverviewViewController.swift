//
//  DiaryOverviewViewController.swift
//  CoronaContact
//

import Reusable
import UIKit
import CoreData

class DiaryOverviewViewController: UIViewController, StoryboardBased, ViewModelBased {
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var diaryTableView: UITableView!
    
    var viewModel: DiaryOverviewViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(contextObjectsDidChange(_:)), name: .NSManagedObjectContextDidSave, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.viewWillAppear()
        
        viewModel?.reloadTableView = { [weak self] in
            self?.diaryTableView.reloadData()
        }
    }
    
    func setupUI() {
        
        title = "diary_overview_title".localized
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "ellipsis"), style: .plain, target: self, action: #selector(exportDiary))
        
        diaryTableView.delegate = self
        diaryTableView.dataSource = self
    }
    
    @objc func contextObjectsDidChange(_ notification: Notification) {
        
        let possibleKeys = [NSInsertedObjectsKey, NSUpdatedObjectsKey, NSDeletedObjectsKey]
        
        let changedObjects = possibleKeys.reduce(into: []) { $0 += Array(notification.userInfo?[$1] as? Set<NSManagedObject> ?? []) }
        
        if changedObjects.compactMap({ $0.entity.superentity }).contains(where: { $0 == BaseDiaryEntry.entity() }) {
            viewModel?.refresh()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func exportDiary() {
        viewModel?.shareDiary()
    }
    
    @IBAction func diaryFaqButtonPressed(_ sender: Any) {
        viewModel?.showDiaryFaq()
    }
}

extension DiaryOverviewViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let viewModel = viewModel else { return }
        viewModel.tableViewCellTapped(index: indexPath.section)
    }
}

extension DiaryOverviewViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let viewModel = viewModel else { return 0 }
        return viewModel.numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let viewModel = viewModel else { return UITableViewCell() }
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "diaryOverviewDayCell", for: indexPath) as? DiaryOverviewDayCell else { return UITableViewCell() }

        cell.accessibilityTraits = .button
        cell.index = indexPath.section
        cell.viewModel = viewModel
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    // Set the spacing between sections
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10
    }
    
    // Make the background color show through
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        
        return headerView
    }
}
