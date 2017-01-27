//
//  UIView+extension.swift
//  commontech
//
//  Created by matata on 17/01/2016.
//  Copyright © 2016 matata. All rights reserved.
//

import UIKit
extension UIView {
    /**
     Set x Position
     
     :param: x CGFloat
     by DaRk-_-D0G
     */
    func setX(x:CGFloat) {
        var frame:CGRect = self.frame
        frame.origin.x = x
        self.frame = frame
    }
    /**
     Set y Position
     
     :param: y CGFloat
     by DaRk-_-D0G
     */
    func setY(y:CGFloat) {
        var frame:CGRect = self.frame
        frame.origin.y = y
        self.frame = frame
    }
    /**
     Set Width
     
     :param: width CGFloat
     by DaRk-_-D0G
     */
    func setWidth(width:CGFloat) {
        var frame:CGRect = self.frame
        frame.size.width = width
        self.frame = frame
    }
    /**
     Set Height
     
     :param: height CGFloat
     by DaRk-_-D0G
     */
    func setHeight(height:CGFloat) {
        var frame:CGRect = self.frame
        frame.size.height = height
        self.frame = frame
    }
    
    // Util function for rounding corner(s) of a view
    func roundCorners(corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.CGPath
        self.layer.mask = mask
    }
    
    // Util function for getting a subview from it's superview by tag
    func checkSubviewWithTag(tag: Int) -> Bool {
        for v in self.subviews {
            if v.tag == tag {
                return true
            }
        }
        return false
    }

    // Util function for getting a subview from it's superview by tag
    func getSubviewWithTag(tag: Int) -> UIView {
        for v in self.subviews {
            if v.tag == tag {
                return v
            }
        }
        return UIView()
    }

    // Util function for removing a subview from it's superview by tag
    func removeSubviewWithTag(tag: Int) -> Bool {
        for v in self.subviews {
            if v.tag == tag {
                v.removeFromSuperview()
                return true
            }
        }
        return false
    }
}
