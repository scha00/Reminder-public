//
//  SlideTransitioningDelegate.swift
//  Reminder
//
//  Created by Sahn Cha on 04/06/2017.
//  Copyright © 2017 Soncode. All rights reserved.
//

import UIKit

class SlideTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    var viewController: UIViewController
    var presentingViewController: UIViewController
    
    init(_ viewController: UIViewController, presenting: UIViewController) {
        self.viewController = viewController
        self.presentingViewController = presenting
        
        super.init()
    }
    
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return SlidePresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideTransitionAnimator(isPresenting: true, duration: 0.5)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideTransitionAnimator(isPresenting: false, duration: 0.5)
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return nil
    }
}
