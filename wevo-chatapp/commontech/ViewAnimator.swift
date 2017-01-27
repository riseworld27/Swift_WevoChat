//
//  ViewAnimator.swift
//  commontech
//
//  Created by Daniel Fassler on 1/25/16.
//  Copyright © 2016 Daniel Fassler. All rights reserved.
//

import UIKit

class ViewAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    // enum for slide direction
    enum SlideDirection {
        case Up, Down, Left, Right
    }
    
    // enum for navigation controller operation type push/pop
    enum OperationType: CGFloat {
        case Push = 1.0, Pop = -1.0
    }

    var duration = 0.35                     // Animation duration
    var direction = SlideDirection.Left     // Slide direction
    var operation = OperationType.Push      // Navigation controller operation type
    var slidingVC : UIViewController!

    // Set slide direction
    func setDirection(slideDirection: SlideDirection) {
        direction = slideDirection
    }

    // Set navigation controller operation type
    func setOperation(operationType: OperationType) {
        operation = operationType
    }

    // Set animation duration (delegate method)
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return duration
    }

    // Transition animation (delegate method)
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        // containerview for animations
        let containerView = transitionContext.containerView()!

        // the destination view controller (transition from)
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!

        // the destination view controller (transition to)
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
                
        if operation == .Push {
            slidingVC = toViewController
            containerView.addSubview(slidingVC.view)
        } else {
            slidingVC = fromViewController
            containerView.addSubview(toViewController.view)
            containerView.addSubview(slidingVC.view)
        }
        
        // Set positions of toViewController before transition (outside of view)
        // According to slide direction e.g.: below view for slide up, above 
        // view for slide down, etc
        
        if operation == .Push {
            switch direction {
            case SlideDirection.Up:
                toViewController.view.center.y += UIScreen.mainScreen().bounds.height
        
            case SlideDirection.Down:
                toViewController.view.center.y -= UIScreen.mainScreen().bounds.height
                
            case SlideDirection.Left:
                toViewController.view.center.x += UIScreen.mainScreen().bounds.width
                
            case SlideDirection.Right:
                toViewController.view.center.x -= UIScreen.mainScreen().bounds.width
            }
        }
        
        UIView.animateWithDuration(transitionDuration(transitionContext),
            animations: {

            // Set final positions of the sliding view controller for animation 
            // according to slide direction (up, down, left, right) and
            // operation type (push/pop) e.g.: below view for slide up on push, 
            // above view for slide up on pop
                
            switch self.direction {
            case SlideDirection.Up:
                self.slidingVC.view.center.y -= (UIScreen.mainScreen().bounds.height * self.operation.rawValue)
                
            case SlideDirection.Down:
                self.slidingVC.view.center.y += (UIScreen.mainScreen().bounds.height * self.operation.rawValue)
                
            case SlideDirection.Left:
                self.slidingVC.view.center.x -= (UIScreen.mainScreen().bounds.width  * self.operation.rawValue)
                
            case SlideDirection.Right: 
                self.slidingVC.view.center.x += (UIScreen.mainScreen().bounds.width * self.operation.rawValue)
            }

            }, completion: { _ in
                transitionContext.completeTransition(true)
            })
        
    }
    
}
