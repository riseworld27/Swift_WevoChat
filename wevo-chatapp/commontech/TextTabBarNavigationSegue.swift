//
//  TextTabBarNavigationSegue.swift
//  commontech
//
//  Created by Daniel Fassler on 1/26/16.
//  Copyright © 2016 matata. All rights reserved.
//

import UIKit

class TextTabBarNavigationSegue: UIStoryboardSegue {

    override func perform() {
        
        let tabBarController = self.sourceViewController as! MyProfileViewController
        let destinationController = self.destinationViewController as UIViewController
        
        for view in tabBarController.placeHolderView.subviews as [UIView] {
            view.removeFromSuperview()
        }
        
        // Add view to placeholder view
        tabBarController.currentViewController = destinationController
        tabBarController.placeHolderView.addSubview(destinationController.view)
        
        // Set autoresizing
        tabBarController.placeHolderView.translatesAutoresizingMaskIntoConstraints = false
        destinationController.view.translatesAutoresizingMaskIntoConstraints = false
        
        let horizontalConstraint = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[v1]-0-|", options: .AlignAllCenterX, metrics: nil, views: ["v1": destinationController.view])
        
        tabBarController.placeHolderView.addConstraints(horizontalConstraint)
        
        let verticalConstraint = NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[v1]-0-|", options: .AlignAllCenterY, metrics: nil, views: ["v1": destinationController.view])
        
        tabBarController.placeHolderView.addConstraints(verticalConstraint)
        
        tabBarController.placeHolderView.layoutIfNeeded()
        destinationController.didMoveToParentViewController(tabBarController)
        
    }

}
