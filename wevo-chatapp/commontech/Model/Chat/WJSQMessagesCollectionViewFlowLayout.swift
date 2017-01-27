//
//  WJSQMessagesCollectionViewFlowLayout.swift
//  commontech
//
//  Created by matata on 12/29/15.
//  Copyright © 2015 matata. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import AVFoundation

class WJSQMessagesCollectionViewFlowLayout: JSQMessagesCollectionViewFlowLayout {
    
    override func messageBubbleSizeForItemAtIndexPath(indexPath: NSIndexPath!) -> CGSize {
        
        var superSize = super.messageBubbleSizeForItemAtIndexPath(indexPath)
        
        superSize = CGSizeMake(UIScreen.mainScreen().bounds.width - 20, superSize.height)
        
        let messageItem = self.collectionView.dataSource?.collectionView(self.collectionView, messageDataForItemAtIndexPath: indexPath)

        if messageItem?.isMediaMessage() == true {
            let media = messageItem?.media!()
            if media!.isKindOfClass(WJSQAudioMediaItem) {
                
                superSize.height = 50
            } else if media!.isKindOfClass(WJSQDateItem) {
                superSize.height = 50
            }
            else {
                
                superSize.height = 300
            }
        }

        return superSize
    }

    
//    override func sizeForItemAtIndexPath(indexPath: NSIndexPath!) -> CGSize {
//
//        let messageBubbleSize = super.messageBubbleSizeForItemAtIndexPath(indexPath)
//        let attributes = self.layoutAttributesForItemAtIndexPath(indexPath) as! JSQMessagesCollectionViewLayoutAttributes
//        
//        var finalHeight = messageBubbleSize.height
//        finalHeight += attributes.cellTopLabelHeight
//        finalHeight += attributes.messageBubbleTopLabelHeight
//        finalHeight += attributes.cellBottomLabelHeight
//
//        return CGSizeMake(UIScreen.mainScreen().bounds.width - 30, ceil(finalHeight))
//    }
    
}
