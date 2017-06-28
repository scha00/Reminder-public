//
//  AddTimeItemCell.swift
//  Reminder
//
//  Created by Sahn Cha on 01/06/2017.
//  Copyright © 2017 Soncode. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class AddTimeItemCell: UITableViewCell {
    
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var deleteImageView: UIImageView!
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var accessaryView: UIView!
    
    enum Status {
        case normal, editing, deletable
    }
    
    static let reuseIdentifier = "TimeItemCell"
    
    let disposeBag = DisposeBag()
    
    let dateFormatter = DateFormatter()
    let numberColor = #colorLiteral(red: 0.7540688515, green: 0.7540867925, blue: 0.7540771365, alpha: 1)
    
    var selectedColor: UIColor? = nil
    
    var status: Status = .deletable {
        didSet {
            if status == .editing {
                UIView.animate(withDuration: 0.2, animations: {
                    self.doneButton.alpha = 1.0
                    self.deleteImageView.alpha = 0.0
                })
            } else if status == .normal {
                UIView.animate(withDuration: 0.2, animations: {
                    self.doneButton.alpha = 0.0
                    self.deleteImageView.alpha = 0.0
                })
            } else if status == .deletable {
                UIView.animate(withDuration: 0.2, animations: {
                    self.doneButton.alpha = 0.0
                    self.deleteImageView.alpha = 1.0
                })
            }
        }
    }
    
    var initialStatus: Status? = nil
    
    var time: Date? = nil {
        didSet {
            guard let time = time else { return }
            self.timePicker.date = time
            self.timeTextField.text = self.dateFormatter.string(from: time)
        }
    }
    
    var timeChangedBlock: ((Date) -> Void)? = nil
    var deleteTappedBlock: (() -> Void)? = nil
    var doneTappedBlock: (() -> Void)? = nil
    
    var number: Int? = nil {
        didSet {
            guard let number = number else { return }
            self.numberLabel.text = "\(number)"
        }
    }
    
    private var timePicker = UIDatePicker()
    
    deinit {
        Logger.MSG("AddTimeItemCell")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.initialize()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func initialize() {
        
        self.numberLabel.font = UIFont(name: "AvenirNext-Regular", size: 10)
        self.numberLabel.textColor = UIColor.white
        self.numberLabel.backgroundColor = numberColor
        self.numberLabel.layer.cornerRadius = 5.0
        self.numberLabel.layer.masksToBounds = true
        
        self.doneButton.setTitleColor(Constants.Color.Icon.Done, for: .normal)
        self.doneButton.alpha = 0.0
        
        self.timeTextField.font = UIFont(name: "AvenirNext-Regular", size: 16)
        self.timeTextField.textColor = #colorLiteral(red: 0.1960784314, green: 0.1960784314, blue: 0.1960784314, alpha: 1)
        self.timeTextField.tintColor = UIColor.clear
        self.timeTextField.rx
            .controlEvent([.editingDidBegin, .editingDidEnd])
            .asObservable()
            .subscribe(onNext: { [unowned self] _ in
                if self.timeTextField.isEditing {
                    self.timeTextField.textColor = self.selectedColor
                    self.numberLabel.backgroundColor = self.selectedColor
                    self.status = .editing
                } else {
                    self.timeTextField.textColor = #colorLiteral(red: 0.1960784314, green: 0.1960784314, blue: 0.1960784314, alpha: 1)
                    self.numberLabel.backgroundColor = self.numberColor
                    self.status = self.initialStatus ?? .normal
                }
            })
            .addDisposableTo(disposeBag)
        
        self.deleteImageView.tintColor = Constants.Color.Icon.InactiveBell
        self.deleteImageView.alpha = 0.0
        
        self.dateFormatter.dateFormat = "h:mm a"
        
        timePicker.datePickerMode = .time
        timePicker.rx
            .value
            .subscribe(onNext: { [unowned self] date in
                self.timeTextField.text = self.dateFormatter.string(from: date)
                self.timeChangedBlock?(date)
            })
            .addDisposableTo(disposeBag)
        timeTextField.inputView = timePicker
        
        self.accessaryView.rx.tapGesture()
            .subscribe(onNext: { [unowned self] gesture in
                if self.status == .deletable {
                    self.deleteTappedBlock?()
                } else if self.status == .editing {
                    self.timeTextField.resignFirstResponder()
                    self.doneTappedBlock?()
                }
            })
            .addDisposableTo(disposeBag)
    }
    
}
