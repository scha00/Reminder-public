//
//  RepeatTypeCell.swift
//  Reminder
//
//  Created by Sahn Cha on 2017. 6. 16..
//  Copyright © 2017년 Soncode. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class RepeatTypeCell: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var repeatButton: UIButton!
    
    @IBOutlet weak var innerTextField: UITextField!
    
    static let reuseIdentifier = "RepeatTypeCell"
    
    let disposeBag = DisposeBag()
    
    private var repeatPicker = UIPickerView()
    
    var repeatType: Enumerated.Repeat = .norepeat {
        didSet {
            self.titleLabel.text = repeatType.cellTitle!
        }
    }
    
    var repeatTypeChangedBlock: ((Enumerated.Repeat) -> Void)? = nil
    var doneTappedBlock: (() -> Void)? = nil
    
    deinit {
        Logger.MSG("RepeatTypeCell")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.initialize()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func initialize() {
        self.iconImageView.tintColor = #colorLiteral(red: 0.5704585314, green: 0.5704723597, blue: 0.5704649091, alpha: 1)
        self.titleLabel.font = UIFont(name: "AvenirNext-Regular", size: 12)
        self.titleLabel.textColor = #colorLiteral(red: 0.4078193307, green: 0.4078193307, blue: 0.4078193307, alpha: 1)
        
        self.innerTextField.inputView = repeatPicker
        self.innerTextField.rx
            .controlEvent([.editingDidBegin, .editingDidEnd])
            .asObservable()
            .subscribe(onNext: { [unowned self] _ in
                if self.innerTextField.isEditing {
                    self.repeatButton.setTitle("done", for: .normal)
                    self.repeatButton.setTitleColor(Constants.Color.Icon.Done, for: .normal)
                } else {
                    self.repeatButton.setTitle("change", for: .normal)
                    self.repeatButton.setTitleColor(Constants.Color.SystemBlue, for: .normal)
                }
            })
            .addDisposableTo(disposeBag)
        
        self.repeatButton.setTitleColor(Constants.Color.SystemBlue, for: .normal)
        self.repeatButton.rx
            .tap
            .subscribe(onNext: { [unowned self] _ in
                if self.innerTextField.isEditing {
                    self.innerTextField.resignFirstResponder()
                    self.doneTappedBlock?()
                } else {
                    self.innerTextField.becomeFirstResponder()
                }
            })
            .addDisposableTo(disposeBag)
        
        self.repeatPicker.dataSource = self
        self.repeatPicker.delegate = self
    }
    
    // MARK: - UIPickerViewDelegate & DataSource
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return DataSources.Repeat.items.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return DataSources.Repeat.items[row].title
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let type = DataSources.Repeat.items[row]
        self.repeatType = type
        self.repeatTypeChangedBlock?(type)
    }
}
