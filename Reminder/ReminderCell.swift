//
//  ReminderCell.swift
//  Reminder
//
//  Created by Sahn Cha on 30/05/2017.
//  Copyright © 2017 Soncode. All rights reserved.
//

import UIKit
import SNKit

class ReminderCell: SwipeCell {

    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var warningImageView: UIImageView!
    
    
    @IBOutlet weak var leftIconImageView: UIImageView!
    @IBOutlet weak var rightIconImageView: UIImageView!
    
    @IBOutlet weak var leftIconTrailConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightIconTrailConstraint: NSLayoutConstraint!
    
    static let reuseIdentifier = "ReminderCell"
    
    static let stopOffset: CGFloat = 40.0
    
    private var foregroundColor: UIColor = UIColor.clear
    private var cellBackgroundColor: UIColor = UIColor.clear
    
    private(set) var cellActive = true
    private(set) var trashFilled = false
    
    var registered = true {
        didSet {
            self.warningImageView.alpha = registered ? 0.0 : 0.3
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.initialize()
    }
    
    private func initialize() {
        self.identifier = ReminderCell.reuseIdentifier
        cellView.layer.cornerRadius = Constants.ReminderCell.CornerRadius
        titleLabel.font = Constants.Font.ReminderCellTitle
        timeLabel.font = Constants.Font.ReminderCellDate
        timeLabel.numberOfLines = 2
        
        warningImageView.alpha = 0.0
        
        leftIconImageView.tintColor = UIColor.clear
        rightIconImageView.tintColor = UIColor.clear//Constants.Color.Icon.TrashBin
    }
    
    func forceLocationLeft(constant: CGFloat) {
        self.leftIconTrailConstraint.constant = constant
    }
    
    func forceLocationRight(constant: CGFloat) {
        self.rightIconTrailConstraint.constant = constant
    }
    
    /// Apply colors & state
    func register(foregroundColor fColor: UIColor, backgroundColor bColor: UIColor, active: Bool) {
        foregroundColor = fColor
        cellBackgroundColor = bColor
        cellActive = active
        applyColor()
    }
    
    func changeActive(_ active: Bool) {
        cellActive = active
        applyColor()
    }
    
    func tintImages() {
        leftIconImageView.tintColor = self.cellActive ? Constants.Color.Icon.InactiveBell : cellBackgroundColor
        rightIconImageView.tintColor = Constants.Color.Icon.TrashBin
    }
    
    func resetIconImage() {
        leftIconImageView.image = self.cellActive ? #imageLiteral(resourceName: "BellNo25") : #imageLiteral(resourceName: "BellFilled25")
        leftIconImageView.tintColor = UIColor.clear
        rightIconImageView.tintColor = UIColor.clear
    }
    
    func trashIcon(filled: Bool) {
        trashFilled = filled
        rightIconImageView.image = filled ? #imageLiteral(resourceName: "TrashFilled25") : #imageLiteral(resourceName: "Trash25")
    }
    
    private func applyColor() {
        if cellActive {
            cellView.backgroundColor = cellBackgroundColor
            timeLabel.textColor = foregroundColor.alpha(0.6)
            titleLabel.textColor = foregroundColor
            warningImageView.tintColor = foregroundColor
        } else {
            cellView.backgroundColor = Constants.Color.Cell.GrayedOutBackground
            timeLabel.textColor = Constants.Color.Cell.GrayedOutForeground.alpha(0.6)
            titleLabel.textColor = Constants.Color.Cell.GrayedOutForeground
            warningImageView.tintColor = Constants.Color.Cell.GrayedOutForeground
        }
    }
    
    /// Properties
    var title: String? = nil {
        didSet {
            titleLabel.text = title
        }
    }
    
    var nextDate: Date? = nil {
        didSet {
//            timeLabel.text = "\(times.count) times a day"
            timeLabel.text = Constants.Sentence.reminderCellNextDateTitle(date: nextDate)
        }
    }

}
