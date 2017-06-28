//
//  SettingAppViewController.swift
//  Reminder
//
//  Created by Sahn Cha on 05/06/2017.
//  Copyright © 2017 Soncode. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SettingAppViewController: UITableViewController {
    
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Tableview
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.tableView.backgroundColor = Constants.Color.Cell.SettingSectionBackground
        
        // Register cell classes
        
        // Rx
        self.view.rx
            .swipeGesture(.left)
            .when(.recognized)
            .subscribe(onNext: { [unowned self] gesture in
                self.dismissViewController()
            })
            .addDisposableTo(disposeBag)
        
        self.navigationItem.rightBarButtonItem?.rx
            .tap
            .subscribe(onNext: { [unowned self] _ in
                self.dismissViewController()
            })
            .addDisposableTo(disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func dismissViewController() {
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return DataSources.SettingApp.sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataSources.SettingApp.find(sectionIndex: section)?.rows.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let row = DataSources.SettingApp.find(sectionIndex: indexPath.section)?.rows[indexPath.row] {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: row.type.rawValue, for: indexPath)
            
            cell.textLabel?.font = Constants.Font.SettingCellTitle
            cell.textLabel?.textColor = Constants.Color.Cell.SettingTitle
            cell.detailTextLabel?.font = Constants.Font.SettingCellDetail
            cell.detailTextLabel?.textColor = Constants.Color.Cell.SettingDetail
            
            switch row.type {
            case .basic:
                
                cell.textLabel?.text = row.title
                cell.imageView?.image = row.icon
                cell.detailTextLabel?.text = row.detail
                
            }
            
            return cell
        }
        
        return tableView.dequeueReusableCell(withIdentifier: DataSources.SettingApp.Cell.basic.rawValue, for: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return DataSources.SettingApp.find(sectionIndex: section)?.title
    }

}
