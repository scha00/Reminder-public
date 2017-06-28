//
//  SettingViewController.swift
//  Reminder
//
//  Created by Sahn Cha on 04/06/2017.
//  Copyright © 2017 Soncode. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SettingViewController: UITableViewController {
    
    let disposeBag = DisposeBag()
    
    deinit {
        Logger.MSG("SettingViewController")
    }

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
            .debug()
            .subscribe(onNext: { [unowned self] _ in
                self.dismissViewController()
            })
            .addDisposableTo(disposeBag)
    }
    
    func tapped() {
        self.dismissViewController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.reloadSections([DataSources.Settings.Section.app.rawValue], with: .none)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func dismissViewController() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return DataSources.Settings.sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataSources.Settings.find(sectionIndex: section)?.rows.count ?? 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let row = DataSources.Settings.find(sectionIndex: indexPath.section)?.rows[indexPath.row] {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: row.type.rawValue, for: indexPath)
            
            cell.textLabel?.font = Constants.Font.SettingCellTitle
            cell.textLabel?.textColor = Constants.Color.Cell.SettingTitle
            cell.detailTextLabel?.font = Constants.Font.SettingCellDetail
            cell.detailTextLabel?.textColor = Constants.Color.Cell.SettingDetail
            
            switch row.type {
            case .basicContinue:
                
                cell.textLabel?.text = row.title
                cell.imageView?.image = row.icon
                cell.detailTextLabel?.text = row.detail
                
            case .buttonExternal:
                
                cell.textLabel?.text = row.title
                cell.textLabel?.textColor = Constants.Color.SystemBlue
                
            }
            
            return cell
        }
        
        return tableView.dequeueReusableCell(withIdentifier: DataSources.Settings.Cell.basicContinue.rawValue, for: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return DataSources.Settings.find(sectionIndex: section)?.title
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let row = DataSources.Settings.find(indexPath: indexPath) {
            if let segue = row.segue {
                self.performSegue(withIdentifier: segue, sender: nil)
            }
            
            else if row.type == .buttonExternal {
                UIApplication.shared.open(URL(string: Constants.AppStoreURL)!, options: [:], completionHandler: nil)
            }
        }
    }

}
