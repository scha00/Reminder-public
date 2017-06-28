//
//  SlidePresentationController.swift
//  Reminder
//
//  Created by Sahn Cha on 04/06/2017.
//  Copyright © 2017 Soncode. All rights reserved.
//

import UIKit

class SlidePresentationController: UIPresentationController {
    
    var widthMultiplier: CGFloat = 0.97
    var slideOffset: CGFloat = 60.0
    
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
        return CGRect(x: 0, y: 0, width: containerView!.bounds.width * widthMultiplier, height: containerView!.bounds.height)
    }
    
    override func presentationTransitionWillBegin() {
//        Logger.MSG()
        
        if let containerView = self.containerView, let coordinator = presentingViewController.transitionCoordinator, let presentingView = self.presentingViewController.view {
            
            if let window = self.presentingViewController.view.window {
                window.insertSubview(backgroundView, at: 0)
            }
            
            dimmingView.alpha = 0.0
            presentingView.addSubview(dimmingView)
            
            coordinator.animate(alongsideTransition: { (context) -> Void in
                presentingView.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
                presentingView.center = CGPoint(x: containerView.bounds.width / 2.0 + self.slideOffset, y: containerView.bounds.height / 2.0 + 5)
                self.dimmingView.alpha = 1.0
            }, completion: nil)
            
            if let presented = self.presentedView {
                let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: containerView.bounds.width * widthMultiplier, height: containerView.bounds.height),
                                        byRoundingCorners: [.topRight, .bottomRight],
                                        cornerRadii: CGSize(width: 10, height: 10))
                let maskLayer = CAShapeLayer()
                
                maskLayer.path = path.cgPath
                presented.layer.mask = maskLayer
                presented.layer.masksToBounds = true
                presented.clipsToBounds = true
            }
        }
    }
    
    override func dismissalTransitionWillBegin() {
//        Logger.MSG()
        
        if let containerView = self.containerView, let coordinator = presentingViewController.transitionCoordinator, let presentingView = self.presentingViewController.view {
            
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

        let viewController = self.presentingViewController as! UINavigationController
        if let mainController = viewController.topViewController as! MainViewController? {
            mainController.willReturnFromTransitioning()
        }
        
    }
    
}
