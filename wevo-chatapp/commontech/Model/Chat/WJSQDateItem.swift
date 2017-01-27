//
//  WJSQPhotoMediaItem.swift
//  commontech
//
//  Created by matata on 12/30/15.
//  Copyright © 2015 matata. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import AVFoundation

class WJSQDateItem: JSQMediaItem {
    
    var cachedImageView : UIView!
    var dateString : String!
    
    override func mediaView() -> UIView! {
        
        //if self.image == nil {
        //    return nil
        //}
        
        if self.cachedImageView == nil {
            
            let size : CGSize = CGSizeMake(UIScreen.mainScreen().bounds.width - 20, 50)
            let view = UIView.init(frame: CGRectMake(20.0, 0.0, size.width, size.height))
            
            let label = UILabel.init(frame: CGRectMake(size.width / 2 - 20, 10.0, size.width / 3, 30))
            label.text = dateString
            label.backgroundColor = UIColor.cyanColor()
            label.textAlignment = NSTextAlignment.Center
            
            label.layer.cornerRadius = 10.0;
            label.clipsToBounds = true
                
            //label.center = CGPointMake(size.width / 2, 0)
            label.font = UIFont(name: "Helvetica Neue", size: 14)
            view.addSubview(label)
            
            //JSQMessagesMediaViewBubbleImageMasker.applyBubbleImageMaskToMediaView(label, isOutgoing: self.appliesMediaViewMaskAsOutgoing)
            //self.cachedImageView.addSubview(label)
            self.cachedImageView = view
        }
        
        return self.cachedImageView
    }
    
}
