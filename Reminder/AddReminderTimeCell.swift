//
//  AddReminderTimeCell.swift
//  Reminder
//
//  Created by Sahn Cha on 01/06/2017.
//  Copyright © 2017 Soncode. All rights reserved.
//

import UIKit

class AddReminderTimeCell: UITableViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    
    static let reuseIdentifier = "ReminderTimeCell"
    
    deinit {
        Logger.MSG("AddReminderTimeCell")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.initialize()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    var reminderCount: Int = 1 {
        didSet {
            self.titleLabel.text = Constants.Sentence.addReminderTime(count: reminderCount)
            self.addButton.isEnabled = (reminderCount >= 6) ? false : true
        }
    }
    
    func initialize() {
        self.iconImageView.tintColor = #colorLiteral(red: 0.5704585314, green: 0.5704723597, blue: 0.5704649091, alpha: 1)
        self.titleLabel.font = UIFont(name: "AvenirNext-Regular", size: 12)
        self.titleLabel.textColor = #colorLiteral(red: 0.4078193307, green: 0.4078193307, blue: 0.4078193307, alpha: 1)
    }
    
    func animateTap() {
        let color = self.contentView.backgroundColor
        self.contentView.backgroundColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
        
        UIView.animate(withDuration: 0.2) {
            self.contentView.backgroundColor = color
        }
    }
    
}
