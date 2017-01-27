//
//  WJSQVideoMediaItem.swift
//  commontech
//
//  Created by matata on 12/23/15.
//  Copyright © 2015 matata. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import AVFoundation

class WJSQVideoMediaItem: JSQVideoMediaItem {
    
    var cachedVideoImageView:UIImageView!
    
    
    override func mediaView() -> UIView! {
        
        if self.fileURL == nil || !self.isReadyToPlay {
            return nil
        }
        
        if self.cachedVideoImageView == nil {
            
            var size : CGSize =  CGSizeMake(UIScreen.mainScreen().bounds.width - 60, 300)
            let videoThumbnail = self.generateThumbnailFromVideo()
            
            let imageView = UIImageView.init(image: videoThumbnail)
            imageView.backgroundColor = UIColor.blackColor()
            imageView.frame = CGRectMake(40.0, 0.0, size.width, size.height)
            imageView.contentMode = UIViewContentMode.Center
            imageView.clipsToBounds = true
            
            let playImageView = UIImageView.init(image: UIImage.init(named: "play"))
            playImageView.contentMode = UIViewContentMode.Center
            playImageView.center = imageView.center
            playImageView.clipsToBounds = true
            
            imageView.addSubview(playImageView)
            
            JSQMessagesMediaViewBubbleImageMasker.applyBubbleImageMaskToMediaView(imageView, isOutgoing: self.appliesMediaViewMaskAsOutgoing)
            self.cachedVideoImageView = imageView            
        }
        
        return self.cachedVideoImageView
    }
    
    func generateThumbnailFromVideo() -> UIImage! {
        
        let asset = AVAsset(URL: self.fileURL)
        let imageGenerator = AVAssetImageGenerator.init(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        let time = CMTimeMake(1, 1)
        do {
            let imageRef = try imageGenerator.copyCGImageAtTime(time, actualTime: nil)
            let thumbnail = UIImage.init(CGImage: imageRef)
            return thumbnail
        }
        catch let error as NSError
        {
            print("Image generation failed with error \(error)")
            return nil
        }
    }
}
