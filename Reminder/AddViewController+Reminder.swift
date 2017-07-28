//
//  AddViewController+Reminder.swift
//  Reminder
//
//  Created by Sahn Cha on 17/06/2017.
//  Copyright © 2017 Soncode. All rights reserved.
//

import UIKit

extension AddViewController {
    
    func registerTableViewCells() {
        self.leftTableView.register(UINib(nibName: "AddTimetableCell", bundle: nil), forCellReuseIdentifier: AddTimetableCell.reuseIdentifier)
        self.leftTableView.register(UINib(nibName: "AddTimeItemCell", bundle: nil), forCellReuseIdentifier: AddTimeItemCell.reuseIdentifier)
        self.leftTableView.register(UINib(nibName: "AddReminderTimeCell", bundle: nil), forCellReuseIdentifier: AddReminderTimeCell.reuseIdentifier)
        
        self.rightTableView.register(UINib(nibName: "AddCalendarCell", bundle: nil), forCellReuseIdentifier: AddCalendarCell.reuseIdentifier)
        self.rightTableView.register(UINib(nibName: "AddDateItemCell", bundle: nil), forCellReuseIdentifier: AddDateItemCell.reuseIdentifier)
        self.rightTableView.register(UINib(nibName: "RepeatTypeCell", bundle: nil), forCellReuseIdentifier: RepeatTypeCell.reuseIdentifier)
        self.rightTableView.register(UINib(nibName: "RepeatSelectorCell", bundle: nil), forCellReuseIdentifier: RepeatSelectorCell.reuseIdentifier)
        self.rightTableView.register(UINib(nibName: "RepeatMonthCell", bundle: nil), forCellReuseIdentifier: RepeatMonthCell.reuseIdentifier)
        self.rightTableView.register(UINib(nibName: "RepeatYearCell", bundle: nil), forCellReuseIdentifier: RepeatYearCell.reuseIdentifier)
    }
    
    func uiAppearanceSettings() {
        // Corner radius effect
        let path = UIBezierPath(roundedRect: self.view.bounds,
                                byRoundingCorners: [.topRight, .topLeft],
                                cornerRadii: CGSize(width: 10, height: 10))
        let maskLayer = CAShapeLayer()
        
        maskLayer.path = path.cgPath
        self.view.layer.mask = maskLayer
        
        // Scroll view
        self.leftTableView.tableFooterView = UIView(frame: CGRect.zero)
        self.rightTableView.tableFooterView = UIView(frame: CGRect.zero)
        
        // Text field settings
        self.titleTextField.layer.cornerRadius = 6.0
        self.titleTextField.font = Constants.Font.AddTextFieldTitle
        self.titleTextField.textColor = Constants.Color.Input.AddTitleText
        self.titleTextField.rx
            .controlEvent([.editingDidEndOnExit])
            .debug()
            .subscribe(onNext: { [unowned self] _ in
                self.titleTextField.resignFirstResponder()
            })
            .addDisposableTo(disposeBag)
        
        // Save button
        self.saveTitleLabel.font = Constants.Font.AddSaveButton
        self.saveTitleLabel.textColor = self.themeForegroundColor
        self.saveTitleLabel.adjustsFontSizeToFitWidth = true
        self.saveView.backgroundColor = self.themeBackgroundColor
        self.saveView.rx.tapGesture()
            .when(.ended)
            .debug()
            .subscribe(onNext: { [unowned self] _ in
                self.saveAndDismiss()
            })
            .addDisposableTo(disposeBag)
        
        // Page control
        self.pageControl.currentPage = 0
    }
    
    func rxObserveSettings() {
        self.times.asObservable()
            //.debug()
            .map { (old: [], new: $0) }     // Will use (old: [Date], new: [Date]) structure
            .scan((old: [], new: [])) { previous, current in
                return (old: previous.new, new: current.new)
            }
            .subscribe(onNext: { [unowned self] times in
                if times.new.count > times.old.count {
                    // If added, avoid duplicates from the old list, and replace it with a new value if found.
                    let last = times.new.last!
                    var candidate: Date? = nil
                    
                    for time in times.old.sorted(by: { $0 < $1 }) {
                        // Find a good candidate for new value
                        if (candidate ?? last).compare(date: time, toGranularity: .minute) == .orderedSame {
                            candidate = (candidate ?? last).date(byAdding: .minute, value: 1)
                        }
                    }
                    
                    if let c = candidate {
                        // Found duplicates and made a candidate -> Assigning new value and reloading cells
                        self.times.value = times.old + [c]
                        self.leftTableView.reloadSections([TableLeft.Section.timeItemCell.rawValue], with: .automatic)
                        self.reloadTimeButtonCell()
                        return
                    }
                }
                
                self.timetableCell.register(times: times.new)
                self.reloadSaveButton()
                
                if times.old.count != times.new.count {
                    self.leftTableView.reloadSections([TableLeft.Section.timeItemCell.rawValue], with: .automatic)
                    self.reloadTimeButtonCell()
                }
            })
            .addDisposableTo(disposeBag)
        
        self.days.asObservable()
            //.debug()
            .map { (old: [], new: $0) }
            .scan((old: [], new: [])) { previous, current in
                return (old: previous.new, new: current.new)
            }
            .subscribe(onNext: { [unowned self] days in
                self.reloadSaveButton()
                
                if days.old.count != days.new.count {
                    if !self.initialImport {
                        self.rightTableView.reloadSections([TableRight.Section.dateItemCell.rawValue], with: .automatic)
                    }
                    self.initialImport = false
                }
            })
            .addDisposableTo(disposeBag)
        
        self.yearRepeatDays.asObservable()
            .map { (old: [], new: $0) }
            .scan((old: [], new: [])) { previous, current in
                return (old: previous.new, new: current.new)
            }
            .subscribe(onNext: { [unowned self] days in
                if days.old.count != days.new.count {
                    if !self.initialImport {
                        self.rightTableView.reloadSections([TableRight.Section.repeatItemCell.rawValue], with: .automatic)
                    }
                    self.initialImport = false
                }
            })
            .addDisposableTo(disposeBag)
        
        self.weekRepeatDays.asObservable().subscribe(onNext: { [unowned self] _ in self.reloadSaveButton() }).addDisposableTo(disposeBag)
        
        self.monthRepeatDays.asObservable().subscribe(onNext: { [unowned self] _ in self.reloadSaveButton() }).addDisposableTo(disposeBag)
    }
    
    func reloadSaveButton() {
        self.madeChange = true
        
        let saveButton = Constants.Sentence.saveReminderButton(repeatType: self.repeatType, times: self.times.value, days: self.days.value, weekdays: self.weekRepeatDays.value, monthdays: self.monthRepeatDays.value)
        
        self.saveTitleLabel.text = saveButton.title
        
        if saveButton.active {
            self.saveView.backgroundColor = self.themeBackgroundColor
            self.saveTitleLabel.textColor = self.themeForegroundColor
        } else {
            self.saveView.backgroundColor = Constants.Color.Cell.GrayedOutBackground
            self.saveTitleLabel.textColor = Constants.Color.Cell.GrayedOutForeground
        }
    }
    
    func saveAndDismiss() {
        Logger.MSG("!! Save And Dismiss !!")
        
        guard self.times.value.count > 0 &&
            ((self.repeatType == .norepeat && self.days.value.count > 0) ||
                (self.repeatType == .day) ||
                (self.repeatType == .week && self.weekRepeatDays.value.count > 0) ||
                (self.repeatType == .month && (self.monthRepeatLastDay.value || self.monthRepeatDays.value.count > 0)) ||
                (self.repeatType == .year && self.yearRepeatDays.value.count > 0))
            else { return }
        
        let calendar = Calendar.current
        let now = Date()
        var foundFutureDate = false
        
        self.madeChange = false
        
        // Check if not all dates are in the past
        if self.repeatType == .norepeat {
            for day in self.days.value {
                for time in self.times.value {
                    let components = DateComponents(year: calendar.component(.year, from: day),
                                                    month: calendar.component(.month, from: day),
                                                    day: calendar.component(.day, from: day),
                                                    hour: calendar.component(.hour, from: time),
                                                    minute: calendar.component(.minute, from: time))
                    if calendar.nextDate(after: now, matching: components, matchingPolicy: .nextTime, repeatedTimePolicy: .first, direction: .forward) != nil {
                        foundFutureDate = true
                        break
                    }
                }
                if foundFutureDate { break }
            }
            
            if !foundFutureDate {
                Logger.MSG("! All dates are in the past: should quit without saving.")
                
                let confirmAlert = UIAlertController(title: NSLocalizedString("sc-alert-past-title", comment: ""),
                                                     message: NSLocalizedString("sc-alert-past-message", comment: ""),
                                                     preferredStyle: .actionSheet)
                confirmAlert.addAction(UIAlertAction(title: NSLocalizedString("co-button-exitanyway", comment: "Exit"),
                                                     style: .default,
                                                     handler: { [unowned self] _ in self.dismissViewController() }))
                confirmAlert.addAction(UIAlertAction(title: NSLocalizedString("co-button-mistake", comment: "Mistake"),
                                                     style: .cancel,
                                                     handler: { [unowned self] _ in self.madeChange = true }))
                self.present(confirmAlert, animated: true, completion: nil)
                return
            }
        }
        
        let system = SNSystem.defaultInstance
        
        var title: String = ""
        if let new = self.titleTextField.text, new.characters.count > 0 {
            title = new.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        }
        
        if self.transitionWork == .reminderModified {
            system.modifyReminder(number: self.editNumber, title: title, color: self.themeColor.data, repeatType: self.repeatType, times: self.times.value, days: self.days.value, weekdays: self.weekRepeatDays.value, monthdays: self.monthRepeatDays.value)
        }
        
        else if self.transitionWork == .reminderAdded {
            system.insertReminder(number: self.editNumber, title: title, color: self.themeColor.data, repeatType: self.repeatType, times: self.times.value, days: self.days.value, weekdays: self.weekRepeatDays.value, monthdays: self.monthRepeatDays.value)
        }
        
        self.dismissViewController()
    }
    
    func dequeueTimetableCell() -> AddTimetableCell {
        let cell = leftTableView.dequeueReusableCell(withIdentifier: AddTimetableCell.reuseIdentifier, for: TableLeft.Section.timetableCell.path()) as! AddTimetableCell
        
        cell.selectedColor = self.themeSelectedColor
        return cell
    }

    func dequeueTimeItemCell(row: Int) -> AddTimeItemCell {
        let cell = leftTableView.dequeueReusableCell(withIdentifier: AddTimeItemCell.reuseIdentifier, for: TableLeft.Section.timeItemCell.path(row: row)) as! AddTimeItemCell
        
        cell.selectedColor = self.themeSelectedColor
        cell.number = row + 1
        cell.time = self.times.value[row]
        cell.status = (row == 0) ? .normal : .deletable
        cell.initialStatus = cell.status
        
        cell.timeChangedBlock = { [unowned self] date in self.times.value[row] = date }
        cell.deleteTappedBlock = { [unowned self] _ in self.times.value.remove(at: row) }
        cell.doneTappedBlock = { [unowned self] _ in
            if let offset = self.timeItemScrollOffset {
                self.leftTableView.setContentOffset(CGPoint(x: 0, y: offset), animated: true)
                self.timeItemScrollOffset = nil
            }
        }
        
        return cell
    }

    func dequeueTimeButtonCell() -> AddReminderTimeCell {
        let cell = leftTableView.dequeueReusableCell(withIdentifier: AddReminderTimeCell.reuseIdentifier, for: TableLeft.Section.timeButtonCell.path()) as! AddReminderTimeCell
        return cell
    }
    
    func dequeueLeftBlankCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = leftTableView.dequeueReusableCell(withIdentifier: "AddLeftCellBlank", for: indexPath)
        cell.textLabel?.text = nil
        cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.width, bottom: 0, right: 0)
        return cell
    }
    
    func dequeueRightBlankCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = rightTableView.dequeueReusableCell(withIdentifier: "AddCellBlank", for: indexPath)
        cell.textLabel?.text = nil
        cell.separatorInset = UIEdgeInsets(top: 0, left: cell.bounds.width, bottom: 0, right: 0)
        return cell
    }

    func dequeueRepeatTypeCell() -> RepeatTypeCell {
        let cell = rightTableView.dequeueReusableCell(withIdentifier: RepeatTypeCell.reuseIdentifier, for: TableRight.Section.repeatTypeCell.path()) as! RepeatTypeCell
        
        cell.repeatType = self.repeatType
        cell.repeatTypeChangedBlock = { [unowned self] type in
            self.repeatType = type
            if let offset = self.repeatTypeAfterScrollOffset, type == .norepeat {
                let offsetPoint = CGPoint(x: self.rightTableView.contentOffset.x, y: offset)
                self.rightTableView.setContentOffset(offsetPoint, animated: true)
            }
            
        }
        cell.doneTappedBlock = { [unowned self] _ in
            if let offset = self.repeatTypeScrollOffset {
                self.rightTableView.setContentOffset(CGPoint(x: 0, y: offset), animated: true)
                self.repeatTypeScrollOffset = nil
                self.repeatTypeAfterScrollOffset = nil
            }
        }
        return cell
    }

    func dequeueCalendarCell() -> AddCalendarCell {
        let cell = rightTableView.dequeueReusableCell(withIdentifier: AddCalendarCell.reuseIdentifier, for: TableRight.Section.calendarCell.path()) as! AddCalendarCell
        
        cell.selectedBackgroundColor = self.themeSelectedColor
        cell.selectedForegroundColor = self.themeForegroundColor
        
        cell.calendarHeightChangedBlock = { [unowned self] height in
            if self.scrollView.contentOffset.x == 0 { return }
            self._calendarCellHeight = height
            self.rightTableView.beginUpdates()
            self.rightTableView.endUpdates()
        }
        
        cell.calendarSelectionChangedBlock = { [unowned self] dates in self.days.value = dates }
        return cell
    }
    
    func dequeueDateItemCell(row: Int) -> AddDateItemCell {
        let cell = rightTableView.dequeueReusableCell(withIdentifier: AddDateItemCell.reuseIdentifier, for: TableRight.Section.dateItemCell.path(row: row)) as! AddDateItemCell
        
        let day = self.days.value[row]
        cell.register(number: row + 1, date: day)
        cell.selectedColor = self.themeSelectedColor
        cell.cellSelected = false
        
        cell.dateLabelTappedBlock = { [unowned self] (selected, date) in
            if let calendarView = self.calendarCell.calendarView, let date = date {
                if selected {
                    
                    let count = self.days.value.count
                    for index in 0..<count {
                        if let otherCell = self.rightTableView.cellForRow(at: TableRight.Section.dateItemCell.path(row: index)) as? AddDateItemCell {
                            if otherCell != cell && otherCell.cellSelected {
                                otherCell.cellSelected = false
                                break
                            }
                        }
                    }
                    
                    calendarView.setCurrentDate(date: date)
                } else {
                    calendarView.selectedDates = self.days.value
                }
            }
        }
        
        cell.deleteTappedBlock = { [unowned self] date in
            var targetIndex: Int? = nil
            for (index, day) in self.days.value.enumerated() {
                if day == date { targetIndex = index; break }
            }
            
            if let index = targetIndex {
                self.days.value.remove(at: index)
                
                if let calendarView = self.calendarCell.calendarView {
                    calendarView.selectedDates = self.days.value
                }
            }
        }
        return cell
    }
    
    func dequeueWeeklyRepeatCell(row: Int) -> RepeatSelectorCell {
        let cell = rightTableView.dequeueReusableCell(withIdentifier: RepeatSelectorCell.reuseIdentifier, for: TableRight.Section.repeatWeekCell.path(row: row)) as! RepeatSelectorCell
        cell.title = Constants.dateFormatter("EEEE").weekdaySymbols[row]
        cell.selectedColor = self.themeSelectedColor
        cell.checked = self.weekRepeatDays.value.contains(row)
        
        cell.selectionChanged = { [unowned self] selected in
            if selected {
                self.weekRepeatDays.value.append(row)
            } else {
                let index = self.weekRepeatDays.value.index(of: row)
                if let index = index {
                    self.weekRepeatDays.value.remove(at: index)
                }
            }
        }
        return cell
    }
    
    func dequeueMonthlyRepeatCell() -> RepeatMonthCell {
        let cell = rightTableView.dequeueReusableCell(withIdentifier: RepeatMonthCell.reuseIdentifier, for: TableRight.Section.repeatMonthCell.path(row: 0)) as! RepeatMonthCell
        cell.calendarSelectionChangedBlock = { [unowned self] (date, selected) in
            let day = Calendar.current.component(.day, from: date)
            if selected {
                self.monthRepeatDays.value.append(day)
            } else {
                let index = self.monthRepeatDays.value.index(of: day)
                if let index = index {
                    self.monthRepeatDays.value.remove(at: index)
                }
            }
        }
        return cell
    }
    
    func dequeueMonthlyLastDayCell() -> RepeatSelectorCell {
        let cell = rightTableView.dequeueReusableCell(withIdentifier: RepeatSelectorCell.reuseIdentifier, for: TableRight.Section.repeatMonthCell.path(row: 1)) as! RepeatSelectorCell
        cell.title = "Last day of month"
        cell.selectedColor = self.themeSelectedColor
        cell.checked = self.monthRepeatLastDay.value
        cell.selectionChanged = { [unowned self] selected in self.monthRepeatLastDay.value = selected }
        return cell
    }
    
    func dequeueYearlyRepeatCell() -> RepeatYearCell {
        let cell = rightTableView.dequeueReusableCell(withIdentifier: RepeatYearCell.reuseIdentifier, for: TableRight.Section.repeatYearCell.path()) as! RepeatYearCell
        
        cell.calendarHeightChangedBlock = { [unowned self] height in
            if self.scrollView.contentOffset.x == 0 { return }
            self._repeatYearCellHeight = height
            self.rightTableView.beginUpdates()
            self.rightTableView.endUpdates()
        }
        
        cell.calendarSelectionChangedBlock = { [unowned self] dates in self.yearRepeatDays.value = dates }
        return cell
    }
    
    func dequeueRepeatItemCell(row: Int) -> AddDateItemCell {
        let cell = rightTableView.dequeueReusableCell(withIdentifier: AddDateItemCell.reuseIdentifier, for: TableRight.Section.repeatItemCell.path(row: row)) as! AddDateItemCell
        
        let day = self.yearRepeatDays.value[row]
        cell.register(number: row + 1, date: day)
        cell.selectedColor = self.themeSelectedColor
        cell.cellSelected = false
        
        cell.dateLabelTappedBlock = { [unowned self] (selected, date) in
            if let calendarView = self.repeatYearCell.calendarView, let date = date {
                if selected {
                    
                    let count = self.yearRepeatDays.value.count
                    for index in 0..<count {
                        if let otherCell = self.rightTableView.cellForRow(at: TableRight.Section.repeatItemCell.path(row: index)) as? AddDateItemCell {
                            if otherCell != cell && otherCell.cellSelected {
                                otherCell.cellSelected = false
                                break
                            }
                        }
                    }
                    
                    calendarView.setCurrentDate(date: date)
                } else {
                    calendarView.selectedDates = self.yearRepeatDays.value
                }
            }
        }

        cell.deleteTappedBlock = { [unowned self] date in
            var targetIndex: Int? = nil
            for (index, day) in self.yearRepeatDays.value.enumerated() {
                if day == date { targetIndex = index; break }
            }
            
            if let index = targetIndex {
                self.yearRepeatDays.value.remove(at: index)
                
                if let calendarView = self.repeatYearCell.calendarView {
                    calendarView.selectedDates = self.yearRepeatDays.value
                }
            }
        }
        return cell
    }
    
    func clearItemCellSelections() {
        if self.days.value.count > 0 {
            for index in 0..<self.days.value.count {
                if let cell = self.rightTableView.cellForRow(at: TableRight.Section.dateItemCell.path(row: index)) as? AddDateItemCell, cell.cellSelected {
                    cell.cellSelected = false
                    break
                }
            }
            self.calendarCell.calendarView?.selectedDates = self.days.value
        }
        
        if self.yearRepeatDays.value.count > 0 {
            for index in 0..<self.yearRepeatDays.value.count {
                if let cell = self.rightTableView.cellForRow(at: TableRight.Section.repeatItemCell.path(row: index)) as? AddDateItemCell, cell.cellSelected {
                    cell.cellSelected = false
                    break
                }
            }
            self.repeatYearCell.calendarView?.selectedDates = self.yearRepeatDays.value
        }
    }
}
