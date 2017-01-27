//
//  WevoNavigationBar.swift
//  commontech
//
//  Created by matata on 12/21/15.
//  Copyright © 2015 matata. All rights reserved.
//

import UIKit

class WevoNavigationBar: UINavigationItem {

    override func awakeFromNib() {
        
        self.titleView = UIImageView.init(image: UIImage.init(named: "wevo_wevo_logo"))
    }
    
    func showBackLeftBtn() {
        
        let backImg = UIImage.init(named: "wevo_back")
        let buttonFrame = CGRectMake(0, 0, backImg!.size.width + 32, backImg!.size.height);
        let backBtn = UIButton.init(frame: buttonFrame)
        backBtn.setImage(backImg, forState: .Normal)
        
        self.leftBarButtonItem = UIBarButtonItem.init(customView: backBtn)
        
    }
    func showHomeBtn() {
        
        let privetImg = UIImage.init(named: "wevo_icon_privet")
        let privetImgHighlighted = UIImage.init(named: "wevo_icon_privet")

        let buttonFrame = CGRectMake(0, 0, privetImg!.size.width + 25, privetImg!.size.height);
        let privetBtn = UIButton.init(frame: buttonFrame)
        privetBtn.setImage(privetImg, forState: .Normal)
        privetBtn.setImage(privetImgHighlighted, forState: .Highlighted)

        let privateDive = UIBarButtonItem.init(customView: privetBtn)
        
        let profileImg = UIImage.init(named: "wevo_icon_my_profile")
        let buttonFrameprofile = CGRectMake(0, 0, profileImg!.size.width + 25 , profileImg!.size.height);
        let profileBtn = UIButton.init(frame: buttonFrameprofile)
        profileBtn.setImage(profileImg, forState: .Normal)
        
        let profile = UIBarButtonItem.init(customView: profileBtn)

        self.setRightBarButtonItems([privateDive, profile], animated: true)

        ///
        let notificationsImg = UIImage.init(named: "wevo_icon_notifications")
        let buttonFramenotifications = CGRectMake(0, 0, notificationsImg!.size.width + 25, notificationsImg!.size.height);
        let notificationsBtn = UIButton.init(frame: buttonFramenotifications)
        notificationsBtn.setImage(notificationsImg, forState: .Normal)
        
        let notifications = UIBarButtonItem.init(customView: notificationsBtn)
        
        
        let filterImg = UIImage.init(named: "wevo_icon_filter")
        let buttonFramefilter = CGRectMake(0, 0, filterImg!.size.width + 25, filterImg!.size.height);
        let filterBtn = UIButton.init(frame: buttonFramefilter)
        filterBtn.setImage(filterImg, forState: .Normal)
        
        let filter = UIBarButtonItem.init(customView: filterBtn)
        
        self.setLeftBarButtonItems([filter, notifications], animated: true)
        
        
    }
    
    func showHomeBackBtn() {
        
        let privetImg = UIImage.init(named: "wevo_icon_privet")
        let buttonFrame = CGRectMake(0, 0, privetImg!.size.width + 25, privetImg!.size.height);
        let privetBtn = UIButton.init(frame: buttonFrame)
        privetBtn.setImage(privetImg, forState: .Normal)
        
        let privateDive = UIBarButtonItem.init(customView: privetBtn)
        
        let profileImg = UIImage.init(named: "wevo_icon_my_profile")
        let buttonFrameprofile = CGRectMake(0, 0, profileImg!.size.width + 25 , profileImg!.size.height);
        let profileBtn = UIButton.init(frame: buttonFrameprofile)
        profileBtn.setImage(profileImg, forState: .Normal)
        
        let profile = UIBarButtonItem.init(customView: profileBtn)
        
        self.setRightBarButtonItems([privateDive, profile], animated: true)
        
        let notificationsImg = UIImage.init(named: "wevo_icon_notifications")
        let buttonFramenotifications = CGRectMake(0, 0, notificationsImg!.size.width + 25, notificationsImg!.size.height);
        let notificationsBtn = UIButton.init(frame: buttonFramenotifications)
        notificationsBtn.setImage(notificationsImg, forState: .Normal)
        
        let notifications = UIBarButtonItem.init(customView: notificationsBtn)
        
        
        let filterImg = UIImage.init(named: "wevo_back")
        let buttonFramefilter = CGRectMake(0, 0, filterImg!.size.width + 25, filterImg!.size.height);
        let filterBtn = UIButton.init(frame: buttonFramefilter)
        filterBtn.setImage(filterImg, forState: .Normal)
        
        let filter = UIBarButtonItem.init(customView: filterBtn)
        
        self.setLeftBarButtonItems([filter, notifications], animated: true)
        
        
    }

    

}
