//
//  AddDateItemCell.swift
//  Reminder
//
//  Created by Sahn Cha on 01/06/2017.
//  Copyright © 2017 Soncode. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class AddDateItemCell: UITableViewCell {
    
    @IBOutlet weak var accessaryView: UIView!
    @IBOutlet weak var deleteImageView: UIImageView!
    
    @IBOutlet weak var numberLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var innerTextField: UITextField!
    
    static let reuseIdentifier = "DateItemCell"
    
    let disposeBag = DisposeBag()
    
    var deleteTappedBlock: ((Date?) -> Void)? = nil
//    var doneTappedBlock: (() -> Void)? = nil
//    var repeatTypeChangedBlock: ((Enumerated.Repeat) -> Void)? = nil
    var dateLabelTappedBlock: ((Bool, Date?) -> Void)? = nil
    
    private var date: Date? = nil
    
//    private var repeatPicker = UIPickerView()
    
    let dateFormat = "E, MMM dd, yyyy"
    let numberColor = #colorLiteral(red: 0.7540688515, green: 0.7540867925, blue: 0.7540771365, alpha: 1)
    
    var selectedColor: UIColor? = nil
    var cellSelected: Bool = false {
        didSet {
            if cellSelected {
                self.numberLabel.backgroundColor = self.selectedColor
                self.dateLabel.textColor = self.selectedColor
            } else {
                self.numberLabel.backgroundColor = self.numberColor
                self.dateLabel.textColor = #colorLiteral(red: 0.1960784314, green: 0.1960784314, blue: 0.1960784314, alpha: 1)
            }
        }
    }
    
//    var repeatType: Enumerated.Repeat = .norepeat {
//        didSet {
//            let cellTitle = repeatType.cellTitle!
//            let width = (cellTitle as NSString).size(attributes: [NSFontAttributeName: self.repeatLabel.font]).width + 5.0
//            
//            self.repeatWidthConstraint.constant = width + 5.0
//            self.repeatLabel.text = cellTitle
//        }
//    }
    
    deinit {
        Logger.MSG("AddDateItemCell")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        initialize()
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
        
        self.dateLabel.font = UIFont(name: "AvenirNext-Regular", size: 16)
        self.dateLabel.textColor = #colorLiteral(red: 0.1960784314, green: 0.1960784314, blue: 0.1960784314, alpha: 1)
        self.dateLabel.adjustsFontSizeToFitWidth = true
        
        self.deleteImageView.tintColor = Constants.Color.Icon.InactiveBell
        
        self.dateLabel.rx
            .tapGesture()
            .when(.ended)
            .subscribe(onNext: { [unowned self] gesture in
                self.cellSelected = !self.cellSelected
                self.dateLabelTappedBlock?(self.cellSelected, self.date)
            })
            .addDisposableTo(disposeBag)
        
//        self.innerTextField.inputView = repeatPicker
//        self.innerTextField.rx
//            .controlEvent([.editingDidBegin, .editingDidEnd])
//            .asObservable()
//            .subscribe(onNext: { [unowned self] _ in
//                if self.innerTextField.isEditing {
//                    self.untilButton.setTitle("done", for: .normal)
//                    self.untilButton.setTitleColor(Constants.Color.Icon.Done, for: .normal)
//                    self.numberLabel.backgroundColor = self.selectedColor
//                    self.dateLabel.textColor = self.selectedColor
//                } else {
//                    self.untilButton.setTitle("delete", for: .normal)
//                    self.untilButton.setTitleColor(Constants.Color.Icon.InactiveBell, for: .normal)
//                    self.numberLabel.backgroundColor = self.numberColor
//                    self.dateLabel.textColor = #colorLiteral(red: 0.1960784314, green: 0.1960784314, blue: 0.1960784314, alpha: 1)
//                }
//            })
//            .addDisposableTo(disposeBag)
        
//        self.repeatLabel.textColor = Constants.Color.SystemBlue
//        self.repeatLabel.rx
//            .tapGesture()
//            .when(.ended)
//            .subscribe(onNext: { [unowned self] _ in
//                self.innerTextField.becomeFirstResponder()
//            })
//            .addDisposableTo(disposeBag)
        
        self.accessaryView.rx
            .tapGesture()
            .when(.ended)
            .subscribe(onNext: { [unowned self] _ in
                self.deleteTappedBlock?(self.date)
            })
            .addDisposableTo(disposeBag)
        
//        self.untilButton.setTitleColor(Constants.Color.Icon.InactiveBell, for: .normal)
//        self.untilButton.rx
//            .tap
//            .subscribe(onNext: { [unowned self] _ in
//                if self.innerTextField.isEditing {
//                    self.innerTextField.resignFirstResponder()
//                    self.doneTappedBlock?()
//                } else {
//                    self.deleteTappedBlock?(self.date)
//                }
//            })
//            .addDisposableTo(disposeBag)
        
//        self.repeatPicker.dataSource = self
//        self.repeatPicker.delegate = self
    }
    
    func register(number: Int, date: Date) {
        self.numberLabel.text = "\(number)"
        self.dateLabel.text = Constants.dateFormatter(dateFormat).string(from: date)
        self.date = date
    }
    
    // MARK: - UIPickerViewDelegate & DataSource
    
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        return 1
//    }
//    
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        return DataSources.Repeat.items.count
//    }
//    
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        return DataSources.Repeat.items[row].title
//    }
//    
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        let type = DataSources.Repeat.items[row]
//        self.repeatType = type
//        self.repeatTypeChangedBlock?(type)
//    }
}
