//
//  RepeatMonthCell.swift
//  Reminder
//
//  Created by Sahn Cha on 17/06/2017.
//  Copyright © 2017 Soncode. All rights reserved.
//

import UIKit
import SNKit

class RepeatMonthCell: UITableViewCell, SNCalendarUnitDelegate {
    
    static let reuseIdentifier = "RepeatMonthCell"
    
    let margin: CGFloat = 15.0
    
    var calendarView = SNCalendarUnitView()
    
    var calendarSelectionChangedBlock: ((Date, Bool) -> Void)? = nil
    
    private var fitted = false
    
    deinit {
        Logger.MSG("RepeatMonthCell")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.initialize()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func initialize() {
        calendarView.calendarUnitDelegate = self
        
        self.layer.zPosition = -1
        
        self.contentView.addSubview(calendarView)
    }
    
    func fitCalendar() -> CGFloat {
        guard fitted == false else { return self.calendarView.getCalendarUnitFrameHeight() + 10.0 }
        
        fitted = true
        self.calendarView.setCalendarUnitFrame(frame: CGRect(x: margin, y: 5, width: frame.width - margin * 2, height: frame.height + 300.0))
        return self.calendarView.getCalendarUnitFrameHeight() + 10.0
    }
    
    func didChangeDateSelection(date: Date, isSelected: Bool) {
        self.calendarSelectionChangedBlock?(date, isSelected)
    }
    
}
