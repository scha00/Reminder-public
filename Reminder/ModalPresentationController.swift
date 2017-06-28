//
//  ModalPresentationController.swift
//  Reminder
//
//  Created by Sahn Cha on 2017. 5. 31..
//  Copyright © 2017년 Soncode. All rights reserved.
//

import UIKit

class ModalPresentationController: UIPresentationController {
    
    var topMargin: CGFloat = 30.0
    var dismissOffset: CGFloat = 120.0
    
    lazy var backgroundView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.containerView!.bounds.width, height: self.containerView!.bounds.height))
        view.backgroundColor = #colorLiteral(red: 0.4756349325, green: 0.4756467342, blue: 0.4756404161, alpha: 1)
        return view
    }()
    
    lazy var dimmingView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.containerView!.bounds.width, height: self.containerView!.bounds.height))
        view.backgroundColor = UIColor.black.alpha(0.2)
        return view
    }()
    
    override var frameOfPresentedViewInContainerView: CGRect {
        return CGRect(x: 0, y: topMargin, width: containerView!.bounds.width, height: containerView!.bounds.height - topMargin)
    }
    
    override func presentationTransitionWillBegin() {
//        Logger.MSG()
        
        if let containerView = self.containerView, let coordinator = presentingViewController.transitionCoordinator, let presentingView = self.presentingViewController.view {
            
            if let window = self.presentingViewController.view.window {
                window.insertSubview(backgroundView, at: 0)
            }
            
            dimmingView.alpha = 0.0
            presentingView.addSubview(dimmingView)
            
            presentingView.clipsToBounds = true
            
            let cornerAnimation = CABasicAnimation(keyPath: "cornerRadius")
            cornerAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
            cornerAnimation.fromValue = 0.0
            cornerAnimation.toValue = 10.0
            cornerAnimation.duration = 0.3
            presentingView.layer.cornerRadius = 10.0
            presentingView.layer.add(cornerAnimation, forKey: "cornerRadius")
            
            coordinator.animate(alongsideTransition: { (context) -> Void in
                presentingView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                presentingView.center = CGPoint(x: containerView.bounds.width / 2.0, y: containerView.bounds.height / 2.0 + 5)
                self.dimmingView.alpha = 1.0
            }, completion: nil)
            
            let presented = self.presentedViewController as! AddViewController
            
            topMargin = containerView.bounds.height * 0.045
            let presentedCenter = CGPoint(x: containerView.bounds.width / 2.0, y: (containerView.bounds.height + topMargin) / 2.0)
            
            presented.didScrollBlock = { [unowned self] offset in
                presented.view.center = CGPoint(x: presentedCenter.x, y: presentedCenter.y + offset)
                if offset > self.dismissOffset {
                    presented.dismissViewController()
                }
            }
        }
    }
    
    override func dismissalTransitionWillBegin() {
//        Logger.MSG()
        
        if let containerView = self.containerView, let coordinator = presentingViewController.transitionCoordinator, let presentingView = self.presentingViewController.view {
            
            let cornerAnimation = CABasicAnimation(keyPath: "cornerRadius")
            cornerAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
            cornerAnimation.fromValue = 10.0
            cornerAnimation.toValue = 0.0
            cornerAnimation.duration = 0.3
            presentingView.layer.cornerRadius = 0.0
            presentingView.layer.add(cornerAnimation, forKey: "cornerRadius")
            
            coordinator.animate(alongsideTransition: { (context) -> Void in
                presentingView.transform = CGAffineTransform.identity
                presentingView.center = CGPoint(x: containerView.bounds.width / 2.0, y: containerView.bounds.height / 2.0)
                self.dimmingView.alpha = 0.0
            }, completion: nil)
        }
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
//        Logger.MSG()
        
        backgroundView.removeFromSuperview()
        dimmingView.removeFromSuperview()
        
        let presented = self.presentedViewController as! AddViewController
        let viewController = self.presentingViewController as! UINavigationController
        if let mainController = viewController.topViewController as! MainViewController? {
            mainController.willReturnFromTransitioning(work: presented.transitionWork)
        }
    }
}
