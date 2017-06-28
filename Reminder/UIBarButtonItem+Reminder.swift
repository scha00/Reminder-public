//
//  UIBarButtonItem+Reminder.swift
//  Reminder
//
//  Created by Sahn Cha on 2017. 6. 8..
//  Copyright © 2017년 Soncode. All rights reserved.
//

import UIKit

extension CAShapeLayer {
    func drawCircleAtLocation(location: CGPoint, withRadius radius: CGFloat, andColor color: UIColor) {
        fillColor = color.cgColor
        strokeColor = color.cgColor
        let origin = CGPoint(x: location.x - radius, y: location.y - radius)
        path = UIBezierPath(ovalIn: CGRect(origin: origin, size: CGSize(width: radius * 2, height: radius * 2))).cgPath
    }
}

private var handle: UInt8 = 0;

extension UIBarButtonItem {
    private var badgeLayer: CAShapeLayer? {
        if let b: AnyObject = objc_getAssociatedObject(self, &handle) as AnyObject? {
            return b as? CAShapeLayer
        } else {
            return nil
        }
    }
    
    func addBadge(color: UIColor = UIColor.red) {
        guard let view = self.value(forKey: "view") as? UIView else { return }
        
        badgeLayer?.removeFromSuperlayer()
        
        // Initialize Badge
        let badge = CAShapeLayer()
        let radius = CGFloat(2)
        let location = CGPoint(x: view.frame.width - (radius + 10), y: (radius + 3))
        badge.drawCircleAtLocation(location: location, withRadius: radius, andColor: color)
        view.layer.addSublayer(badge)
        
        // Save Badge as UIBarButtonItem property
        objc_setAssociatedObject(self, &handle, badge, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
   
    func removeBadge() {
        badgeLayer?.removeFromSuperlayer()
    }
}
