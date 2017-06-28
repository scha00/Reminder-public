//
//  SettingLibrariesViewController.swift
//  Reminder
//
//  Created by Sahn Cha on 06/06/2017.
//  Copyright © 2017 Soncode. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SettingLibrariesViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    let disposeBag = DisposeBag()
    
    var licenseLabel: UILabel? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        // Rx
        self.view.rx
            .swipeGesture(.left)
            .when(.recognized)
            .subscribe(onNext: { [unowned self] gesture in
                self.dismissViewController()
            })
            .addDisposableTo(disposeBag)
        
        self.navigationItem.rightBarButtonItem?.rx
            .tap
            .subscribe(onNext: { [unowned self] _ in
                self.dismissViewController()
            })
            .addDisposableTo(disposeBag)
        
        licenseLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height))
        licenseLabel?.numberOfLines = 0
        
        let titleAttributes = [NSFontAttributeName: Constants.Font.LibraryTitle,
                               NSForegroundColorAttributeName: UIColor.darkGray]
        let contentAttributes = [NSFontAttributeName: Constants.Font.LibraryContent,
                                 NSForegroundColorAttributeName: UIColor.darkGray.alpha(0.8)]
        let string = NSMutableAttributedString()
        
        for license in Acknowledgement.list {
            let title = NSAttributedString(string: license.title + "\n\n", attributes: titleAttributes)
            let content = NSAttributedString(string: license.content! + "\n\n\n", attributes: contentAttributes)
            
            string.append(title)
            string.append(content)
        }
        
        licenseLabel?.attributedText = string
        self.scrollView.addSubview(licenseLabel!)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if let label = licenseLabel {
            label.frame = CGRect(x: 20, y: 20, width: self.view.bounds.width - 40, height: 10000)
            label.sizeToFit()
            
            self.scrollView.contentSize = CGSize(width: self.view.bounds.width, height: label.bounds.height + 40)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func dismissViewController() {
        self.dismiss(animated: true, completion: nil)
    }

}
