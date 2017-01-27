//
//  MyProfileViewController.swift
//  commontech
//
//  Created by Daniel Fassler on 1/26/16.
//  Copyright © 2016 matata. All rights reserved.
//

import UIKit

class MyProfileViewController: UIViewController {

    @IBOutlet var tabBarButtons: [UIButton]!
    var currentViewController: UIViewController?
    @IBOutlet weak var navItem: WevoNavigationBar!
    @IBOutlet weak var placeHolderView: UIView!    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.initNavBar()

        // Set the first tab shown
        if(tabBarButtons.count > 0) {
            performSegueWithIdentifier("vcMyActivities", sender: tabBarButtons[0])
        }

    }

    func initNavBar() {
        self.navItem!.showHomeBtn()
        self.navItem!.showBackLeftBtn()
        
        (self.navItem.leftBarButtonItem?.customView as! UIButton).addTarget(self, action: "backAction:", forControlEvents: UIControlEvents.TouchUpInside)
        
//        (self.navItem.rightBarButtonItems![0].customView as! UIButton).addTarget(self, action: "privetAction:", forControlEvents: UIControlEvents.TouchUpInside)
        
//        (self.navItem.rightBarButtonItems![1].customView as! UIButton).addTarget(self, action: "myProfileAction:", forControlEvents: UIControlEvents.TouchUpInside)
    }

    func backAction(sender:AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        let availableIdentifiers = ["vcMyActivities","vcPublicProfile","vcEditProfile","vcManagePermissions"]
        
        // Setup custom text tab bar selected tab color
        if(availableIdentifiers.contains(segue.identifier!)) {
            
            for btn in tabBarButtons {
                btn.selected = false
                btn.titleLabel?.textColor = UIColor.blackColor()
            }
            
            let senderButton = sender as! UIButton
            senderButton.selected = true
            senderButton.titleLabel?.textColor = UIColor.whiteColor()
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
