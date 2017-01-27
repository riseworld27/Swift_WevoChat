//
//  UINavigationController+extension.swift
//  commontech
//
//  Created by Daniel Fassler on 1/25/16.
//  Copyright © 2016 matata. All rights reserved.
//

import Foundation

let transition = ViewAnimator()

extension UINavigationController : UINavigationControllerDelegate {
    
    // Allow custom transitions for push/pop viewcontrollers
    public func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if (operation == .Push) {
            transition.setOperation(ViewAnimator.OperationType.Push)
            return transition
        }
        
        if (operation == .Pop) {
            transition.setOperation(ViewAnimator.OperationType.Pop)
            return transition
        }
        
        return nil;
    }
    
    // Setting slide transition direction (when pushing/popping)
    func setDirection(direction: ViewAnimator.SlideDirection) {
        self.delegate = self
        transition.setDirection(direction)
    }
    
}


