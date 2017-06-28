//
//  MainViewController.swift
//  Reminder
//
//  Created by Sahn Cha on 30/05/2017.
//  Copyright © 2017 Soncode. All rights reserved.
//

import UIKit
import Sphere
import SNKit
import RxSwift
import RxCocoa

class MainViewController: UICollectionViewController, ReminderLayoutDelegate {

    let disposeBag = DisposeBag()
    
    var sphere: Sphere! = Sphere.defaultInstance
    var system: SNSystem! = SNSystem.defaultInstance
    
    /// Current theme info
    lazy var theme: SNTheme = { [unowned self] in
        return self.system.theme
    }()
    
    /// New item's color
    var nextThemeColor: SNThemeColor? = nil
    
    /// Sphere data
    var reminderData: SPFetchResult<Reminder>? = nil
    
    // Default cell size
    var defaultCellSize = CGSize(width:Constants.Screen.Width - (Constants.ReminderCell.Padding * 2), height: Constants.ReminderCell.DefaultHeight)
    
    // Transition delegates
    var addTransitionDelegate: ModalTransitionDelegate? = nil
    var settingTransitionDelegate: SlideTransitionDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let _ = self.theme
        if let layout = collectionView?.collectionViewLayout as? ReminderLayout { layout.delegate = self }

        // Register cell classes
        self.collectionView!.register(UINib(nibName: "ReminderCell", bundle: nil), forCellWithReuseIdentifier: ReminderCell.reuseIdentifier)
        
        // Sphere integration settings
        reminderData = sphere.object(Reminder.self).sorted([NSSortDescriptor(key: "next", ascending: true), NSSortDescriptor(key: "number", ascending: true)])
        try! reminderData?.addNotificationBlock(block: self.collectionView!.applySphereChanges)
        
        // Other settings
        uiSetting()
        
        system.localNotificationReceivedForeground = { [unowned self] _ in
            self.prepareReminders()
            self.refreshTitle()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        _ = NotificationCenter.default.rx
            .notification(Constants.Identifier.Notification.ThemeChanged)
            .debug()
            .takeUntil(rx.methodInvoked(#selector(viewWillDisappear(_:))))
            .subscribe(onNext: { [unowned self] notification in
                if let newTheme = notification.object as? SNTheme {
                    self.theme = newTheme
                    self.collectionView!.reloadData()
                }
            })
        
        _ = NotificationCenter.default.rx
            .notification(Notification.Name.UIApplicationWillEnterForeground)
            .debug()
            .takeUntil(rx.methodInvoked(#selector(viewWillDisappear(_:))))
            .subscribe(onNext: { [unowned self] notification in
                self.prepareReminders()
                self.refreshTitle()
            })
        
        checkThemeValidity()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        prepareReminders()
        refreshTitle()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        defaultCellSize.width = size.width - (Constants.ReminderCell.Padding * 2)
    }
    
    // MARK: - Methods
    
    func willReturnFromTransitioning(work: Enumerated.TransitionWorkType = .none) {
        self.addTransitionDelegate = nil
        self.settingTransitionDelegate = nil
        
        if work == .reminderAdded {
            let _ = self.generateNextThemeColor()
        } else if work == .reminderModified {

        }
        
        if work != .none {
            prepareReminders()
        }
        
        refreshTitle()
        checkThemeValidity()
    }
    
    func checkThemeValidity() {
        if self.theme.id != Constants.Theme.Basic.id && system.purchaseDate(Constants.Key.IAP.ThemePack.title) == nil {
            // Not purchased
            let themeAlart = UIAlertController(title: NSLocalizedString("sc-alert-theme-title", comment: "Theme Title"),
                                               message: NSLocalizedString("sc-alert-theme-message", comment: "Theme Message"),
                                               preferredStyle: .alert)
            themeAlart.addAction(UIAlertAction(title: NSLocalizedString("co-button-okay", comment: "Okay"),
                                               style: .default,
                                               handler: { [unowned self] _ in self.system.change(theme: Constants.Theme.Basic) }))
            self.present(themeAlart, animated: true, completion: nil)
        }
    }
    
    func uiSetting() {
        self.navigationItem.rightBarButtonItems?[0].rx.tap
            .subscribe(onNext: { [unowned self] value in
                self.performSegue(withIdentifier: Constants.Identifier.Segue.Add, sender: nil)
            })
            .addDisposableTo(disposeBag)
        
        self.collectionView?.refreshControl = UIRefreshControl()
        self.collectionView?.refreshControl?.layer.zPosition = -1
        self.collectionView?.refreshControl?.rx
            .controlEvent([.valueChanged])
            .subscribe(onNext: {[unowned self] _ in
                self.prepareReminders()
                self.collectionView?.refreshControl?.endRefreshing()
            })
            .addDisposableTo(disposeBag)
    }
    
    func refreshTitle() {
        if let data = reminderData {
            self.title = Constants.Title(count: data.count)
        }
    }
    
    func generateNextThemeColor() -> SNThemeColor {
        let colorCount = self.theme.backgroundColors.count
        var color = SNThemeColor()
        var exclude: [Data]? = nil
        
        if let reminderCount = reminderData?.count {
            Logger.MSG("\(reminderCount)")
            if reminderCount > 0 {
                if reminderCount < colorCount * 2 {
                    var remiderColors: [Data] = []
                    for data in reminderData! {
                        remiderColors.append(data.color! as Data)
                    }
                    exclude = remiderColors
                }
                color = SNThemeColor.generateThemeColor(exclude: exclude, indexCount: colorCount)
            }
        }
        
        self.nextThemeColor = color
        Logger.MSG("\(color.firstIndex):\(color.secondIndex):\(color.mixRate)")
        return color
    }
    
    func deleteReminder(cell: ReminderCell) {
        if let indexPath = self.collectionView!.indexPath(for: cell), let item = reminderData?[indexPath.item] {
            let deleteAlert = UIAlertController(title: cell.title,
                                                message: NSLocalizedString("sc-alert-delete-message", comment: "Delete Message"),
                                                preferredStyle: .actionSheet)
            deleteAlert.addAction(UIAlertAction(title: NSLocalizedString("co-button-delete", comment: "Delete"),
                                                style: .destructive, handler: { _ in
                                                    self.system.deleteReminder(uniqueId: item.uniqueId!)
                                                    self.refreshTitle()
            }))
            deleteAlert.addAction(UIAlertAction(title: NSLocalizedString("co-button-cancel", comment: "Cancel"),
                                                style: .cancel,
                                                handler: nil))
            self.present(deleteAlert, animated: true, completion: nil)
        }
    }
    
    func prepareReminders() {
        // 0. Check local notification authorization status
        // 1. Calculate next ring date for each reminder, then update sphere.
        // 2. If there're reminders that do not have next ring date, remove them from the Coredata.
        
        Notifications.defaultInstance.checkAuthorizationStatus { (granted) in
            
            if !granted {
                if UserDefaults.standard.bool(forKey: Constants.Key.UserDefaults.AuthRequest) == true { return }
                
                Logger.MSG("not granted")
                let confirmAlert = UIAlertController(title: NSLocalizedString("sc-alert-notification-title", comment: "Notification Title"),
                                                     message: NSLocalizedString("sc-alert-notification-message", comment: "Notification Message"),
                                                     preferredStyle: .actionSheet)
                confirmAlert.addAction(UIAlertAction(title: NSLocalizedString("co-button-gotit", comment: "Got it"),
                                                     style: .cancel,
                                                     handler: nil))
                self.present(confirmAlert, animated: true, completion: {
                    UserDefaults.standard.set(true, forKey: Constants.Key.UserDefaults.AuthRequest)
                })
            }
                
            else {
                // Check registered states
                Logger.MSG("register check")
                for reminder in self.reminderData! {
                    if !reminder.registered {
                        self.system.requestLocalNotifications(reminder: reminder.uniqueId!)
                    }
                }
            }
        }
        
        for reminder in self.reminderData! {
            let next = system.nextNotificationDateForReminder(uniqueId: reminder.uniqueId!)
            
            if let next = next {    // Has next ring date
                Logger.MSG(next)
                try! self.sphere.write { reminder.next = next as NSDate }
            }
            
            else {                  // Expired
                try! self.sphere.write { [unowned self] _ in
                    self.sphere.delete(reminder)
                }
            }
        }
        
//        self.collectionView?.reloadData()
//        self.collectionView?.collectionViewLayout.prepare(forCollectionViewUpdates: [])
//        self.collectionView?.collectionViewLayout.invalidateLayout()
//        self.collectionView?.performBatchUpdates(nil, completion: nil)
    }
    
    
    // MARK: - UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let data = reminderData {
            return data.count
        } else {
            return 0
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ReminderCell.reuseIdentifier, for: indexPath) as! ReminderCell
    
        // Configure the cell
        cell.addBeginSwipeBlock { [unowned self] _ in self.collectionView?.isScrollEnabled = false }
        cell.addEndSwipeBlock { [unowned self] _ in self.collectionView?.isScrollEnabled = true }
        cell.clipsToBounds = false
        cell.delegate = self
        
        if let data = reminderData {
            let item = data[indexPath.item]
            let themeColor = SNThemeColor.fromData(item.color as Data?)
            let backgroundColor = self.theme.backgroundColor(forThemeColor: themeColor)
            
            cell.register(foregroundColor: theme.foregroundColor(forThemeColor: themeColor), backgroundColor: backgroundColor, active: item.ring)
            cell.registered = item.registered
            cell.title = item.title
            cell.nextDate = item.next as Date?
            cell.resetIconImage()
        }
    
        return cell
    }
    
    // MARK: - ReminderLayoutDelegate
    
    func collectionView(_ collectionView: UICollectionView, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        if let text = reminderData?[indexPath.item].title {
            let height = text.height(withConstrainedWidth: defaultCellSize.width - 120.0, font: Constants.Font.ReminderCellTitle!)
            return CGSize(width: defaultCellSize.width, height: defaultCellSize.height + (height - Constants.ReminderCell.TitleRowHeight))
        }
        return defaultCellSize
    }
    
    func cellPaddingForCollectionView(_ collectionView: UICollectionView) -> CGFloat {
        return Constants.ReminderCell.Padding
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == Constants.Identifier.Segue.Add {
            self.addTransitionDelegate = ModalTransitionDelegate(self, presenting: segue.destination)
            segue.destination.modalPresentationStyle = .custom
            segue.destination.transitioningDelegate = self.addTransitionDelegate
            
            let addViewController = segue.destination as! AddViewController
            let color = self.nextThemeColor ?? self.generateNextThemeColor()
            addViewController.themeColor = color
            
            var number: Int32 = 0
            for data in self.reminderData! {
                if data.number > number { number = data.number }
            }
            
            addViewController.editNumber = number + 1
            addViewController.transitionWork = .reminderAdded
        }
            
        else if segue.identifier == Constants.Identifier.Segue.Modify {
            if let reminder = sender as? Reminder {
                self.addTransitionDelegate = ModalTransitionDelegate(self, presenting: segue.destination)
                segue.destination.modalPresentationStyle = .custom
                segue.destination.transitioningDelegate = self.addTransitionDelegate
                
                let addViewController = segue.destination as! AddViewController
                let color = SNThemeColor(data: reminder.color! as Data)
                let repeatType = Enumerated.Repeat(rawValue: Int(reminder.repeatType))!
                
                addViewController.themeColor = color
                addViewController.editNumber = reminder.number
                addViewController.reminderTitle = reminder.title
                
                var times: [Date] = []
                var dates: [Date] = []
                var weekdays: [Int] = []    // Week repeat
                var days: [Int] = []        // Month & Year repeat
                var endOfMonth: Bool = false
                
                let timeList = reminder.times!.sortedArray(using: [NSSortDescriptor(key: "number", ascending: true)]) as! [RTime]
                let dayList = reminder.days!.sortedArray(using: [NSSortDescriptor(key: "number", ascending: true)]) as! [RDay]
                
                for time in timeList.map({ $0.time! as Date }) {
                    times.append(time)
                }
                
                for day in dayList {
                    if let date = day.date { dates.append(date as Date) }
                    weekdays.append(Int(day.weekday))
                    days.append(Int(day.day))
                    if day.endOfMonth { endOfMonth = true }
                }
                
                if repeatType != .week { weekdays = [] }
                if repeatType != .month { days = [] }

                addViewController.times.value = times
                addViewController.days.value = dates
                addViewController.weekRepeatDays.value = weekdays
                addViewController.monthRepeatDays.value = days
                addViewController.monthRepeatLastDay.value = endOfMonth
                addViewController.initialImport = true
                addViewController.importRepeatType = repeatType
                addViewController.transitionWork = .reminderModified
            }
        }
        
        else if segue.identifier == Constants.Identifier.Segue.Setting {
            self.settingTransitionDelegate = SlideTransitionDelegate(self, presenting: segue.destination)
            segue.destination.modalPresentationStyle = .custom
            segue.destination.transitioningDelegate = self.settingTransitionDelegate
        }
    }

}


extension MainViewController: SwipeCellDelegate {
    
    func shouldStartSwipe(_ cell: SwipeCell) -> Bool {
        return !(self.collectionView!.isDecelerating || self.collectionView!.isDragging)
    }
    
    func allowedSwipeLevel(forCell cell: SwipeCell, direction: SwipeCell.Direction) -> SwipeCell.Level {
        return .single
    }
    
    func swipeDistance(forCell cell: SwipeCell, direction: SwipeCell.Direction, level: SwipeCell.Level) -> CGFloat {
        return (direction == .toRight) ? 80.0 : 100.0
    }
    
    func rubberbandIntensity(forCell cell: SwipeCell, direction: SwipeCell.Direction, level: SwipeCell.Level) -> CGFloat {
        return 0.8
    }
    
    func didChangeTransition(inCell cell: SwipeCell, transition: CGFloat, offset: CGFloat) {
        let reminderCell = cell as! ReminderCell
        let stopOffset = ReminderCell.stopOffset
        
        if offset > 0 && offset < stopOffset {
            reminderCell.forceLocationLeft(constant: stopOffset)
        } else if offset >= stopOffset {
            reminderCell.forceLocationLeft(constant: offset)
        }
        
        if offset < 0 && offset > -stopOffset - 15.0 {
            reminderCell.forceLocationRight(constant: stopOffset)
        } else if offset <= -stopOffset - 15.0 {
            reminderCell.forceLocationRight(constant: -offset - 15.0)
        }
    }
    
    func didStartTransition(_ cell: SwipeCell, direction: SwipeCell.Direction) {
        let reminderCell = cell as! ReminderCell
        reminderCell.tintImages()
    }
    
    func didEndTransition(_ cell: SwipeCell, direction: SwipeCell.Direction) {
        let reminderCell = cell as! ReminderCell
        
        if direction == .toRight {
            if let indexPath = self.collectionView!.indexPath(for: cell), let item = reminderData?[indexPath.item] {
                reminderCell.trashIcon(filled: false)
                
                try! self.sphere.write {
                    item.ring = reminderCell.cellActive
                }
                
                if reminderCell.cellActive {
                    self.system.requestLocalNotifications(reminder: item.uniqueId)
                } else {
                    self.system.removeLocalNotifications(reminder: item.uniqueId)
                }
            }
        }
        
        if direction == .toLeft && reminderCell.trashFilled {
            // Delete alert
            let reminderCell = cell as! ReminderCell
            reminderCell.trashIcon(filled: false)
            
//            self.collectionView?.reloadData()
//            self.collectionView?.collectionViewLayout.prepare(forCollectionViewUpdates: [])
//            self.collectionView?.collectionViewLayout.invalidateLayout()
            self.collectionView?.performBatchUpdates(nil, completion: { [unowned self] _ in
                self.deleteReminder(cell: reminderCell)
            })
        }
        
        reminderCell.resetIconImage()
    }
    
    func didTrigger(inCell cell: SwipeCell, level: SwipeCell.Level, direction: SwipeCell.Direction) {
        let reminderCell = cell as! ReminderCell
        
        if direction == .toRight {
            if reminderCell.cellActive {
                reminderCell.changeActive(false)
            } else {
                reminderCell.changeActive(true)
            }
        }
        
        if direction == .toLeft {
            reminderCell.trashIcon(filled: true)
        }
    }
    
    func canceledTrigger(inCell cell: SwipeCell, level: SwipeCell.Level, direction: SwipeCell.Direction) {
        let reminderCell = cell as! ReminderCell
        
        if direction == .toRight {
            if reminderCell.cellActive {
                reminderCell.changeActive(false)
            } else {
                reminderCell.changeActive(true)
            }
        }
        
        if direction == .toLeft {
            reminderCell.trashIcon(filled: false)
        }
    }
    
    func didImmediatelyTapSwipeCell(_ cell: SwipeCell) {
        if let indexPath = self.collectionView?.indexPath(for: cell), let item = reminderData?[indexPath.item] {
            self.performSegue(withIdentifier: Constants.Identifier.Segue.Modify, sender: item)
        }
    }
    
}
