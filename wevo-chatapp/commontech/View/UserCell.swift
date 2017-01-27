//
//  UserCell.swift
//  commontech
//
//  Created by matata on 12/01/2016.
//  Copyright © 2016 matata. All rights reserved.
//

import UIKit

class UserCell: UICollectionViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var cornerViewCOntainer: UIView!
    
    override func preferredLayoutAttributesFittingAttributes(layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        return layoutAttributes
    }

//    override func prepareForReuse() {
//        print("cell off screen")
//    }
    
//    override var selected: Bool {
//        get {
//            return super.selected
//        }
//        set {
//            if newValue {
//               // self.photoImage.alpha = 0.5
//                print("selected")
//            //    self.backgroundColor = UIColor(white: 1, alpha: 1)
//            } else if newValue == false {
//               // self.photoImage.alpha = 1.0
//                print("deselected")
//            //    self.backgroundColor = UIColor(white: 1, alpha: 0)
//
//            }
//        }
//    }
//
//    override var highlighted: Bool {
//        get {
//            return super.selected
//        }
//        set {
//            if newValue {
//                self.photoImage.alpha = 1.0
//                print("highlighted")
//            } else if newValue == false {
//                self.photoImage.alpha = 0.5
//                print("deselected")
//                
//            }
//        }
//    }

}
