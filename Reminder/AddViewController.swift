//
//  AddViewController.swift
//  Reminder
//
//  Created by Sahn Cha on 2017. 5. 31..
//  Copyright © 2017년 Soncode. All rights reserved.
//

import UIKit
import SNKit
import RxSwift
import RxCocoa
import Hue

class AddViewController: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var leftTableView: UITableView!
    @IBOutlet weak var rightTableView: UITableView!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var saveView: UIView!
    @IBOutlet weak var saveTitleLabel: UILabel!
    
    let disposeBag = DisposeBag()
    
    /// Observable TIMES property
    var times: Variable<[Date]> = Variable([])
    
    /// Observable DAYS property
    var days: Variable<[Date]> = Variable([])
    
    // Observable REPEAT DAYS properties
//    var repeatDays: Variable<[Enumerated.Repeat: [Any]]>
    var weekRepeatDays: Variable<[Int]> = Variable([])
    var monthRepeatDays: Variable<[Int]> = Variable([])
    var monthRepeatLastDay: Variable<Bool> = Variable(false)
    var yearRepeatDays: Variable<[Date]> = Variable([])
    
    // REPEAT setting
    var repeatType: Enumerated.Repeat = .norepeat {
        didSet {
            let sections = [TableRight.Section.calendarCell.rawValue,
                            TableRight.Section.dateItemCell.rawValue,
                            TableRight.Section.repeatWeekCell.rawValue,
                            TableRight.Section.repeatMonthCell.rawValue,
                            TableRight.Section.repeatYearCell.rawValue,
                            TableRight.Section.repeatItemCell.rawValue]
            self.rightTableView.reloadSections(IndexSet(sections), with: .automatic)
            self.clearItemCellSelections()
            
            self.reloadSaveButton()
        }
    }
    
    var importRepeatType: Enumerated.Repeat? = nil
    
    // Theme Color Setting
    private var _defaultThemeColor: SNThemeColor = SNThemeColor()
    var _themeColor: SNThemeColor? = nil
    var themeColor: SNThemeColor {
        get {
            guard let c = _themeColor else { return _defaultThemeColor }
            return c
        }
        set(value) { _themeColor = value }
    }
    
    var themeBackgroundColor: UIColor {
        let theme = SNSystem.defaultInstance.theme
        return theme.backgroundColor(forThemeColor: self.themeColor)
    }
    
    var themeForegroundColor: UIColor {
        let theme = SNSystem.defaultInstance.theme
        return theme.foregroundColor(forThemeColor: self.themeColor)
    }
    
    var themeSelectedColor: UIColor {
        return themeBackgroundColor.isDark ? themeBackgroundColor : themeForegroundColor
    }
    
    // Identification number of the given reminder
    var editNumber: Int32 = 0
    
    // Title of the reminder
    var reminderTitle: String? = nil
    
    // Check if 'days.value' changes because of initial import
    var initialImport = true
    
    // Root will know what was done here using this property
    var transitionWork: Enumerated.TransitionWorkType = .none
    
    // Callback to transition controller for the 'cancel gesture'
    var didScrollBlock: ((CGFloat) -> Void)? = nil
    
    // Confirm changes
    var madeChange = false
    
    // Scroll offsets
    var timeItemScrollOffset: CGFloat? = nil
    var repeatTypeScrollOffset: CGFloat? = nil
    var repeatTypeAfterScrollOffset: CGFloat? = nil
    
    var _calendarCellHeight: CGFloat? = nil
    var _repeatMonthCellHeight: CGFloat? = nil
    var _repeatYearCellHeight: CGFloat? = nil
    
    // DataSource for tableViews
    struct TableLeft {
        static let sections: [Section] = [.timetableCell, .timeItemCell, .timeButtonCell, .timeFooterCell]
        enum Section: Int {
            case timetableCell = 0, timeItemCell, timeButtonCell, timeFooterCell
            
            var height: CGFloat {
                switch self {
                case .timetableCell:    return 140.0
                case .timeItemCell:     return 55.0
                case .timeButtonCell:   return 55.0
                case .timeFooterCell:   return 55.0
                }
            }
            func path(row: Int = 0) -> IndexPath { return IndexPath(row: row, section: self.rawValue) }
        }
    }
    
    struct TableRight {
        static let sections: [Section] = [.calendarCell, .dateItemCell, .repeatTypeCell, .repeatWeekCell, .repeatMonthCell, .repeatYearCell, .repeatItemCell, .dateFooterCell]
        enum Section: Int {
            case calendarCell = 0, dateItemCell, repeatTypeCell, repeatWeekCell, repeatMonthCell, repeatYearCell, repeatItemCell, dateFooterCell
            
            var height: CGFloat {
                switch self {
                case .calendarCell:     return 300.0    // default: needs calculation
                case .dateItemCell:     return 55.0
                case .repeatTypeCell:   return 55.0
                case .repeatWeekCell:   return 45.0
                case .repeatMonthCell:  return 45.0
                case .repeatYearCell:   return 300.0    // default: needs calculation
                case .repeatItemCell:   return 55.0
                case .dateFooterCell:   return 55.0
                }
            }
            func path(row: Int = 0) -> IndexPath { return IndexPath(row: row, section: self.rawValue) }
        }
    }
    
    // Cells that need to be preserved in memory
    lazy var timetableCell: AddTimetableCell = { [unowned self] _ in return self.dequeueTimetableCell() }()
    lazy var timeButtonCell: AddReminderTimeCell = { [unowned self] _ in return self.dequeueTimeButtonCell() }()
    lazy var calendarCell: AddCalendarCell = { [unowned self] _ in return self.dequeueCalendarCell() }()
    lazy var repeatMonthCell: RepeatMonthCell = { [unowned self] _ in return self.dequeueMonthlyRepeatCell() }()
    lazy var repeatYearCell: RepeatYearCell = { [unowned self] _ in return self.dequeueYearlyRepeatCell() }()
    
    deinit {
        Logger.MSG("AddViewController")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uiSettings()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.transitionWork = .none
        
        if self.times.value.count == 0 && self.days.value.count == 0 {
            
            // Default
            let hourAfter = Date().date(byAdding: .hour, value: 1)
            let hourAfterDay = NSCalendar.current.isDateInToday(hourAfter) ? Date() : Date().date(byAdding: .day, value: 1)
            
            self.times.value.append(hourAfter)
            self.days.value.append(hourAfterDay)
        }
        
        else {
            self.titleTextField.text = self.reminderTitle
        }
        
        if let calendarView = self.calendarCell.calendarView {
            calendarView.selectedDates = days.value
        }
        
        // Keyboard notification
        _ = NotificationCenter.default.rx
            .notification(Notification.Name.UIKeyboardWillShow)
            .takeUntil(rx.methodInvoked(#selector(viewWillDisappear(_:))))
            .subscribe(onNext: { [unowned self] notification in
                if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                    let keyboardHeight = keyboardSize.height
                    
                    // Count right-tableview's date item cells
                    let count = self.times.value.count
                    for row in 0..<count {
                        if let cell = self.leftTableView.cellForRow(at: TableLeft.Section.timeItemCell.path(row: row)) as? AddTimeItemCell {
                            if cell.timeTextField.isEditing {
                                let total = self.leftTableView.frame.size.height - keyboardHeight + 65.0/*save button*/
                                let offsetPoint = CGPoint(x: 0, y: cell.frame.origin.y - total + TableLeft.Section.timeItemCell.height)
                                
                                if offsetPoint.y < 0 { return }
                                
                                self.timeItemScrollOffset = self.leftTableView.contentOffset.y
                                self.leftTableView.setContentOffset(offsetPoint, animated: true)
                                return
                            }
                        }
                    }
                    
                    if let cell = self.rightTableView.cellForRow(at: TableRight.Section.repeatTypeCell.path()) as? RepeatTypeCell {
                        if cell.innerTextField.isEditing {
                            let total = self.rightTableView.frame.size.height - keyboardHeight + 65.0/*save button*/
                            let offsetPoint = CGPoint(x: 0, y: cell.frame.origin.y - total + TableRight.Section.repeatTypeCell.height)
                            
                            if offsetPoint.y < 0 { return }
                            
                            self.repeatTypeAfterScrollOffset = offsetPoint.y
                            self.repeatTypeScrollOffset = self.rightTableView.contentOffset.y
                            self.rightTableView.setContentOffset(offsetPoint, animated: true)
                            return
                        }
                    }
                }
            })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.reminderTitle == nil {
            self.titleTextField.text = NSLocalizedString("str-default-title", comment: "")
//            self.titleTextField.becomeFirstResponder()
        }
        
        if let type = self.importRepeatType {
            self.repeatType = type
            self.rightTableView.reloadData()
            
            if type == .month {
                self.repeatMonthCell.calendarView.select(days:self.monthRepeatDays.value)
            }
        }
        
        self.madeChange = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func uiSettings() {
        // UI
        self.registerTableViewCells()
        self.uiAppearanceSettings()
        
        // Rx observe
        self.rxObserveSettings()
    }
    
    func reloadTimeButtonCell() {
        self.timeButtonCell.reminderCount = self.times.value.count
        self.titleTextField.resignFirstResponder()
    }
    
    func dismissViewController() {
        if self.madeChange {
            let saveAlert = UIAlertController(title: NSLocalizedString("sc-alert-unsaved-title", comment: ""),
                                              message: NSLocalizedString("sc-alert-unsaved-message", comment: ""),
                                              preferredStyle: .actionSheet)
            saveAlert.addAction(UIAlertAction(title: NSLocalizedString("co-button-discard", comment: "Discard"),
                                              style: .destructive,
                                              handler: { _ in
                                                self.didScrollBlock = nil
                                                self.dismiss(animated: true, completion: nil)
            }))
            saveAlert.addAction(UIAlertAction(title: NSLocalizedString("co-button-savequit", comment: "Save & Quit"),
                                              style: .default,
                                              handler: { _ in
                                                self.saveAndDismiss()
            }))
            saveAlert.addAction(UIAlertAction(title: NSLocalizedString("co-button-cancel", comment: "Cancel"),
                                              style: .cancel,
                                              handler: nil))
            self.present(saveAlert, animated: true, completion: nil)
        }
        
        else {
            self.didScrollBlock = nil
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.leftTableView || scrollView == self.rightTableView {
            if scrollView.contentOffset.y <= 0 { didScrollBlock?(-scrollView.contentOffset.y) }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            let pageNumber = round(scrollView.contentOffset.x / scrollView.frame.size.width)
            pageControl.currentPage = Int(pageNumber)
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == self.leftTableView { return TableLeft.sections.count }
        else { return TableRight.sections.count }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == self.leftTableView {
            return (section == TableLeft.Section.timeItemCell.rawValue) ? self.times.value.count : 1
        }
        
        else {
            if self.repeatType == .norepeat {
                switch section {
                case TableRight.Section.calendarCell.rawValue:      return 1
                case TableRight.Section.dateItemCell.rawValue:      return self.days.value.count
                case TableRight.Section.repeatTypeCell.rawValue:    return 1
                case TableRight.Section.dateFooterCell.rawValue:    return 1
                default:                                            return 0
                }
            }
            
            else if self.repeatType == .day {
                switch section {
                case TableRight.Section.repeatTypeCell.rawValue:    return 1
                case TableRight.Section.dateFooterCell.rawValue:    return 1
                default:                                            return 0
                }
            }
            
            else if self.repeatType == .week {
                switch section {
                case TableRight.Section.repeatTypeCell.rawValue:    return 1
                case TableRight.Section.repeatWeekCell.rawValue:    return 7
                case TableRight.Section.dateFooterCell.rawValue:    return 1
                default:                                            return 0
                }
            }
            
            else if self.repeatType == .month {
                switch section {
                case TableRight.Section.repeatTypeCell.rawValue:    return 1
                case TableRight.Section.repeatMonthCell.rawValue:   return 1
                case TableRight.Section.dateFooterCell.rawValue:    return 1
                default:                                            return 0
                }
            }
            
            else if self.repeatType == .year {
                switch section {
                case TableRight.Section.repeatTypeCell.rawValue:    return 1
                case TableRight.Section.repeatYearCell.rawValue:    return 1
                case TableRight.Section.repeatItemCell.rawValue:    return self.yearRepeatDays.value.count
                case TableRight.Section.dateFooterCell.rawValue:    return 1
                default:                                            return 0
                }
            }
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == self.leftTableView {
            
            switch indexPath.section {
            case TableLeft.Section.timetableCell.rawValue:  return self.timetableCell
            case TableLeft.Section.timeItemCell.rawValue:   return self.dequeueTimeItemCell(row: indexPath.row)
            case TableLeft.Section.timeButtonCell.rawValue: return self.timeButtonCell
            default:                                        return self.dequeueLeftBlankCell(indexPath: indexPath)
            }
            
        } else {

            switch indexPath.section {
            case TableRight.Section.calendarCell.rawValue:
                let cell = self.calendarCell
                cell.fitCalendar()
                self._calendarCellHeight = cell.height
                return cell
                
            case TableRight.Section.dateItemCell.rawValue:  return self.dequeueDateItemCell(row: indexPath.row)
            case TableRight.Section.repeatTypeCell.rawValue:return self.dequeueRepeatTypeCell()
            case TableRight.Section.repeatWeekCell.rawValue:return self.dequeueWeeklyRepeatCell(row: indexPath.row)
            case TableRight.Section.repeatMonthCell.rawValue:
                if indexPath.row == 0 {
                    let cell = self.repeatMonthCell
                    self._repeatMonthCellHeight = cell.fitCalendar()
                    return cell
                }
                else { return self.dequeueMonthlyLastDayCell() }
                
            case TableRight.Section.repeatYearCell.rawValue:
                let cell = self.repeatYearCell
                self._repeatYearCellHeight = cell.fitCalendar()
                return cell
                
            case TableRight.Section.repeatItemCell.rawValue:return self.dequeueRepeatItemCell(row: indexPath.row)
            default:                                        return self.dequeueRightBlankCell(indexPath: indexPath)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == self.leftTableView {
            if let height = TableLeft.Section(rawValue: indexPath.section)?.height {
                return height
            }
        }
        
        else if tableView == self.rightTableView {
            if indexPath.section == TableRight.Section.calendarCell.rawValue {
                return self._calendarCellHeight ?? TableRight.Section.calendarCell.height
            }
            
            else if indexPath.section == TableRight.Section.repeatMonthCell.rawValue && indexPath.row == 0 {
                return self._repeatMonthCellHeight ?? TableRight.Section.repeatMonthCell.height
            }
            
            else if indexPath.section == TableRight.Section.repeatYearCell.rawValue {
                return self._repeatYearCellHeight ?? TableRight.Section.repeatYearCell.height
            }
            
            if let height = TableRight.Section(rawValue: indexPath.section)?.height {
                return height
            }
        }
        
        return 55.0
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == self.leftTableView {
            if indexPath.section == TableLeft.Section.timeButtonCell.rawValue {
                
                self.timeButtonCell.animateTap()
                let count = self.times.value.count
                if count <= 5 {
                    self.times.value.append(Date().date(byAdding: .hour, value: 1))
                }
            }
        }
    }
    
    // MARK: - UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.titleTextField, let text = textField.text {
            let newLength = text.characters.count + string.characters.count - range.length
            return newLength <= 100
        }
        return true
    }

}
