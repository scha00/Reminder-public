//
//  RepeatYearCell.swift
//  Reminder
//
//  Created by Sahn Cha on 18/06/2017.
//  Copyright © 2017 Soncode. All rights reserved.
//

import UIKit
import SNKit

class RepeatYearCell: UITableViewCell, SNCalendarDelegate {

    static let reuseIdentifier = "RepeatYearCell"
    
    let margin: CGFloat = 15.0
    
    var calendarView: SNCalendar? = nil
    var calendarHeightChangedBlock: ((CGFloat) -> Void)? = nil
    var calendarSelectionChangedBlock: (([Date]) -> Void)? = nil
    
    private var fitted = false
    
    deinit {
        Logger.MSG("RepeatYearCell")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initialize()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func initialize() {
        calendarView = SNCalendar(frame: CGRect(x: margin, y: -10, width: self.contentView.bounds.width - margin * 2, height: self.contentView.bounds.height))
        calendarView?.calendarDelegate = self
        calendarView?.titleFont = UIFont(name: "AvenirNext-Medium", size: 14)!
        calendarView?.headerFont = UIFont(name: "AvenirNext-Regular", size: 10)!
        
        self.layer.zPosition = -1
        self.contentView.addSubview(calendarView!)
    }
    
    func fitCalendar() -> CGFloat {
        guard fitted == false else { return self.calendarView!.calendarHeight + 5.0 }
        
        fitted = true
        self.calendarView?.frame = CGRect(x: margin, y: 0, width: frame.width - margin * 2, height: frame.height + 100.0)
        return self.calendarView!.calendarHeight + 5.0
    }
    
    // MARK: - CalendarDelegate
    
    func calendar(_ calendar: SNCalendar, didChangeDateSelection dates: [Date]) {
        calendarSelectionChangedBlock?(dates)
    }
    
    func calendar(_ calendar: SNCalendar, didChangeYear year: Int, didChangeMonth month: Int, willChangeHeight height: CGFloat) {
        calendarHeightChangedBlock?(height + 5.0)
    }
    
}
