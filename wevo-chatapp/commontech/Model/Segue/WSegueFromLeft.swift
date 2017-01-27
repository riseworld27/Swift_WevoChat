//
//  WSegueFromLeft.swift
//  wevo
//
//  Created by matata on 12/1/15.
//

import UIKit
import QuartzCore

class WSegueFromLeft: UIStoryboardSegue {

    override func perform() {
        let src: UIViewController = self.sourceViewController
        let dst: UIViewController = self.destinationViewController 
        let transition: CATransition = CATransition()
        let timeFunc : CAMediaTimingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        transition.duration = 0.35
        transition.timingFunction = timeFunc
        transition.type = kCATransitionPush
        transition.subtype = kCATransitionFromLeft
        src.view.layer.addAnimation(transition, forKey: kCATransitionFromLeft)
        dst.view.layer.addAnimation(transition, forKey: kCATransition)

        src.navigationController!.pushViewController(dst, animated: false)
    }
    
}
