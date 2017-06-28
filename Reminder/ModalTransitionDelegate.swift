//
//  ModalTransitionDelegate.swift
//  Reminder
//
//  Created by Sahn Cha on 2017. 5. 31..
//  Copyright © 2017년 Soncode. All rights reserved.
//

import UIKit

class ModalTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    var viewController: UIViewController
    var presentingViewController: UIViewController
    
    init(_ viewController: UIViewController, presenting: UIViewController) {
        self.viewController = viewController
        self.presentingViewController = presenting
        
        super.init()
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return ModalPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return nil
    }
}
