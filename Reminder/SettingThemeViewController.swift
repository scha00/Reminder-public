//
//  SettingThemeViewController.swift
//  Reminder
//
//  Created by Sahn Cha on 05/06/2017.
//  Copyright © 2017 Soncode. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SettingThemeViewController: UITableViewController {
    
    enum PurchaseButtonStatus: String {
        case loading = "Loading"
        case ready = ""
        case reload = "Reload"
        case purchased = "Purchased"
    }

    let disposeBag = DisposeBag()
    
    var system: SNSystem! = SNSystem.defaultInstance
    
    var purchaseDate: Date? = nil
    var priceString: String? = nil
    
    var purchaseButtonStatus: PurchaseButtonStatus = .loading {
        didSet {
            let indexPath = IndexPath(row: 0, section: DataSources.SettingTheme.Section.purchase.rawValue)
            let cell = self.tableView.cellForRow(at: indexPath)
            cell?.detailTextLabel?.text = purchaseButtonStatus.rawValue
            
            if purchaseButtonStatus == .ready, let price = self.priceString {
                cell?.detailTextLabel?.text = price
            }
        }
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
            .subscribe(onNext: { [unowned self] _ in
                self.dismissViewController()
            })
            .addDisposableTo(disposeBag)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        _ = NotificationCenter.default.rx
            .notification(Constants.Identifier.Notification.PaymentQueueUpdated)
            .takeUntil(rx.methodInvoked(#selector(viewWillDisappear(_:))))
            .subscribe(onNext: { notification in
                self.checkPurchases()
                self.tableView.reloadData()
            });
        
        checkPurchases()
    }
    
    func checkPurchases() {
        purchaseDate = system.purchaseDate(Constants.Key.IAP.ThemePack.title)
        
        if purchaseDate == nil {
            
            system.requestProductsInfo() { (products) in
                if let product = products?.first {
                    
                    let formatter = NumberFormatter()
                    formatter.numberStyle = .currency
                    formatter.locale = product.priceLocale
                    
                    self.priceString = formatter.string(from: product.price)
                    self.purchaseButtonStatus = .ready
                    
                } else {
                    
                    // Tap to reload
                    self.purchaseButtonStatus = .reload
                    
                }
            }
        }
        
        else {
            self.purchaseButtonStatus = .purchased
        }
    }
    
    func dismissViewController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return DataSources.SettingTheme.sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataSources.SettingTheme.find(sectionIndex: section)?.rows.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let section = DataSources.SettingTheme.find(sectionIndex: indexPath.section) {
            
            let row = section.rows[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: row.type.rawValue, for: indexPath)
            
            switch row.type {
            case .theme:
                
                cell.textLabel?.font = Constants.Font.SettingCellMicro
                cell.textLabel?.textColor = Constants.Color.Cell.SettingMicroTitle
                cell.detailTextLabel?.font = Constants.Font.SettingCellDetail
                cell.detailTextLabel?.textColor = Constants.Color.Cell.SettingDetail
                
                cell.textLabel?.text = (section == .themePack && self.purchaseDate == nil) ? "" : "owned"
                cell.detailTextLabel?.text = row.title
                cell.imageView?.image = #imageLiteral(resourceName: "Check24")

                if row.detail == system.theme.id {
                    cell.imageView?.alpha = 1.0
                } else {
                    cell.imageView?.alpha = 0.1
                }
                
            case .buttonPurchase:
                
                cell.textLabel?.font = Constants.Font.SettingCellTitle
                cell.textLabel?.textColor = Constants.Color.Cell.SettingTitle
                cell.detailTextLabel?.font = Constants.Font.SettingCellDetail
                cell.detailTextLabel?.textColor = Constants.Color.Cell.SettingDetail
                
                cell.textLabel?.text = row.title
                cell.detailTextLabel?.text = (self.purchaseButtonStatus != .ready) ? self.purchaseButtonStatus.rawValue : self.priceString!
                cell.imageView?.image = #imageLiteral(resourceName: "Gift24")
                
            case .buttonRestore:
                
                cell.textLabel?.font = Constants.Font.SettingCellTitle
                cell.textLabel?.textColor = Constants.Color.SystemBlue
                cell.textLabel?.text = row.title
                
            }
            
            return cell
        }
        
        return tableView.dequeueReusableCell(withIdentifier: DataSources.SettingTheme.Cell.theme.rawValue, for: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return DataSources.SettingTheme.find(sectionIndex: section)?.title
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == DataSources.SettingTheme.Section.main.rawValue || indexPath.section == DataSources.SettingTheme.Section.themePack.rawValue {
            if let row = DataSources.SettingTheme.find(sectionIndex: indexPath.section)?.rows[indexPath.row], let theme = Constants.Theme.find(byId: row.detail) {
                
                system.change(theme: theme)
                tableView.reloadData()
            }
        }
        
        if indexPath.section == DataSources.SettingTheme.Section.purchase.rawValue {
            if purchaseButtonStatus == .reload {
                // Reload
                purchaseButtonStatus = .loading
                checkPurchases()
            }
            
            else if purchaseButtonStatus == .ready {
                // Make purchase
                system.buyThemePack()
            }
        }
        
        if indexPath.section == DataSources.SettingTheme.Section.restore.rawValue {
            // Restore purchases
            system.restorePurchases()
        }
    }

}
