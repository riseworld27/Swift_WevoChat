//
//  WJSQAudioMediaItem.swift
//  commontech
//
//  Created by matata on 12/30/15.
//  Copyright © 2015 matata. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import AVFoundation

class WJSQAudioMediaItem: JSQVideoMediaItem
{
    
    var cachedAudioView:UIView!
    
    override func mediaView() -> UIView! {
        
        if self.fileURL == nil || !self.isReadyToPlay {
            return nil
        }
        
        if self.cachedAudioView == nil {
            print(UIScreen.mainScreen().bounds.width)
            let size : CGSize =  CGSizeMake(UIScreen.mainScreen().bounds.width - UIScreen.mainScreen().bounds.width / 16 * 5, 50)
            
            //let size : CGSize =  CGSizeMake(UIScreen.mainScreen().bounds.width, 50)
            
            let view = UIView.init(frame:CGRectMake(UIScreen.mainScreen().bounds.width / 4, 0.0, size.width, size.height))
            view.backgroundColor = UIColor(red: 252/255, green: 246/255, blue: 164/255, alpha: 1.0)

            let imagePlayImage = UIImage.init(named: Images.ChatAudioPlayMsg)
            let playImageView = UIImageView.init(frame: CGRectMake(100, 0, (imagePlayImage?.size.width)!, (imagePlayImage?.size.height)!))
            
            playImageView.image = imagePlayImage
            playImageView.center = CGPointMake(UIScreen.mainScreen().bounds.width / 32 * 11, 24)
            
            let audioMessageImage = UIImage.init(named: Images.ChatAudioImageMsg)
            
            let audioMessageView = UIImageView.init(frame: CGRectMake(100, 0, (audioMessageImage?.size.width)!, (audioMessageImage?.size.height)!))
            audioMessageView.image = audioMessageImage
            
            audioMessageView.center = CGPointMake(UIScreen.mainScreen().bounds.width / 16 * 9, 24)
            
            let label = UILabel(frame: CGRectMake(100, 0, 50, 21))
            label.center = CGPointMake(UIScreen.mainScreen().bounds.width / 16 * 13, 24)
            label.textAlignment = NSTextAlignment.Right
            label.textColor = UIColor.grayColor()
            label.text = audioDuration
            
            view.addSubview(playImageView)
            view.addSubview(audioMessageView)
            view.addSubview(label)
            
            JSQMessagesMediaViewBubbleImageMasker.applyBubbleImageMaskToMediaView(view, isOutgoing: self.appliesMediaViewMaskAsOutgoing)
            self.cachedAudioView = view
        }
        
        return self.cachedAudioView
    }

}
