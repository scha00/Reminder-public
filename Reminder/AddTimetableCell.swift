//
//  AddTimetableCell.swift
//  Reminder
//
//  Created by Sahn Cha on 2017. 6. 14..
//  Copyright © 2017년 Soncode. All rights reserved.
//

import UIKit
import SNKit

class AddTimetableCell: UITableViewCell {

    static let reuseIdentifier = "TimetableCell"
    
    let margin: CGFloat = 15.0
    
    var timetableView: SNTimetable? = nil
    
    var selectedColor: UIColor? = nil {
        didSet {
            if let color = selectedColor {
                timetableView?.timeViewColor = color
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        initialize()
    }
    
    deinit {
        Logger.MSG("AddTimetableCell")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func initialize() {
        timetableView = SNTimetable(frame: CGRect(x: margin, y: 10, width: self.contentView.bounds.width - margin * 2, height: self.contentView.bounds.height - 20))
        timetableView?.hourViewTextColor = #colorLiteral(red: 0.7540688515, green: 0.7540867925, blue: 0.7540771365, alpha: 1)
        timetableView?.hourViewTextFont = UIFont(name: "AvenirNext-Regular", size: 10)!
        
        self.contentView.addSubview(timetableView!)
    }
    
    func register(times: [Date]) {
        timetableView?.times = times
    }
    
    override var frame: CGRect {
        didSet {
            timetableView?.setNewFrame(CGRect(x: margin, y: 10, width: self.contentView.bounds.width - margin * 2, height: self.contentView.bounds.height - 20))
        }
    }
}
