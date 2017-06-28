//
//  SlideTransitionAnimator.swift
//  Reminder
//
//  Created by Sahn Cha on 04/06/2017.
//  Copyright © 2017 Soncode. All rights reserved.
//

import UIKit

class SlideTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    let isPresenting: Bool
    let duration: TimeInterval
    
    init(isPresenting: Bool, duration: TimeInterval) {
        self.isPresenting = isPresenting
        self.duration = duration
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return self.duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning)  {
        if isPresenting {
            animatePresentationWithTransitionContext(transitionContext)
        } else {
            animateDismissalWithTransitionContext(transitionContext)
        }
    }
    
    func animatePresentationWithTransitionContext(_ transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        if let toController = transitionContext.viewController(forKey: .to) {
            let toView = toController.view!
            
            let finalFrame = transitionContext.finalFrame(for: toController)
            containerView.addSubview(toView)
            
            toView.frame = CGRect(x: -finalFrame.size.width, y: finalFrame.origin.y, width: finalFrame.size.width, height: finalFrame.size.height)
            
            UIView.animate(withDuration: self.duration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .allowUserInteraction, animations: {
                toView.frame = finalFrame
            }, completion: {(completed: Bool) -> Void in
                transitionContext.completeTransition(completed)
            })
        }
    }
    
    func animateDismissalWithTransitionContext(_ transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        
        if let fromView = transitionContext.view(forKey: UITransitionContextViewKey.from) {
            containerView.addSubview(fromView)
            
            UIView.animate(withDuration: self.duration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .allowUserInteraction, animations: {
                fromView.frame = CGRect(x: -fromView.frame.size.width, y: fromView.frame.origin.y, width: fromView.frame.size.width, height: fromView.frame.size.height)
            }, completion: {(completed: Bool) -> Void in
                transitionContext.completeTransition(completed)
            })
        }
    }
    
}
