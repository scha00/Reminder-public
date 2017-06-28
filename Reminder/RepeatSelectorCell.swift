//
//  RepeatSelectorCell.swift
//  Reminder
//
//  Created by Sahn Cha on 2017. 6. 16..
//  Copyright © 2017년 Soncode. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class RepeatSelectorCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var checkImageView: UIImageView!
    
    static let reuseIdentifier = "RepeatSelectorCell"
    
    let disposeBag = DisposeBag()
    
    var title: String? {
        get { return self.titleLabel.text }
        set(value) { self.titleLabel.text = value }
    }
    
    var checked: Bool = false {
        didSet {
            self.checkImageView.alpha = checked ? 1.0 : 0.0
            self.titleLabel.textColor = checked ? selectedColor : #colorLiteral(red: 0.4078193307, green: 0.4078193307, blue: 0.4078193307, alpha: 1)
        }
    }
    
    var selectedColor: UIColor = Constants.Color.SystemBlue {
        didSet {
            self.checkImageView.tintColor = selectedColor
            
            if checked {
                self.titleLabel.textColor = selectedColor
            }
        }
    }
    
    var selectionChanged: ((Bool) -> Void)? = nil
    
    deinit {
        Logger.MSG("RepeatSelectorCell")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.initialize()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func initialize() {
        self.checkImageView.tintColor = selectedColor
        self.checkImageView.alpha = 0.0
        self.titleLabel.font = UIFont(name: "AvenirNext-Regular", size: 16)
        self.titleLabel.textColor = #colorLiteral(red: 0.4078193307, green: 0.4078193307, blue: 0.4078193307, alpha: 1)
        
        self.contentView.rx
            .tapGesture()
            .when(.ended)
            .subscribe(onNext: { [unowned self] gesture in
                self.checked = !self.checked
                self.selectionChanged?(self.checked)
            })
            .addDisposableTo(disposeBag)
    }
    
}
