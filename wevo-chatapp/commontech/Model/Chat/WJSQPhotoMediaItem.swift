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

class WJSQPhotoMediaItem: JSQPhotoMediaItem {

    var cachedImageView : UIImageView!
    
    override func mediaView() -> UIView! {
        
        
        if self.image == nil {
            return nil
        }
        
        if self.cachedImageView == nil {
            
            let size : CGSize = CGSizeMake(UIScreen.mainScreen().bounds.width - 60, 300)
            let imageView = UIImageView(image: self.image)
            imageView.frame = CGRectMake(40.0, 0.0, size.width, size.height)
            imageView.contentMode = UIViewContentMode.ScaleAspectFill
            imageView.clipsToBounds = true
            
            JSQMessagesMediaViewBubbleImageMasker.applyBubbleImageMaskToMediaView(imageView, isOutgoing: self.appliesMediaViewMaskAsOutgoing)
            self.cachedImageView = imageView
        }
        
        return self.cachedImageView
    }

}
