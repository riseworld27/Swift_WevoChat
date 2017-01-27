//
//  UserDataCell.swift
//  commontech
//
//  Created by matata on 19/11/2015.
//  Copyright © 2015 matata. All rights reserved.
//


import UIKit
import QuartzCore

protocol UserDataCellDelegate {
    // indicates that the given item has been deleted
    func toDoItemSink(operationItem: String)
    func toDoItemFloat(operationItem: String)

}

class UserDataCell: UITableViewCell {
    @IBOutlet weak var lblName: UILabel!
    
    var delegate: UserDataCellDelegate?
    var tickLabel: UILabel, crossLabel: UILabel
    let gradientLayer = CAGradientLayer()
    var originalCenter = CGPoint()
    var deleteOnDragRelease = false
    var completeOnDragRelease = false
    let label: StrikeThroughText

    var operationItem: String? {
        didSet {
            label.text = self.operationItem!
  
        }
    }
   // @IBOutlet weak var viewMembersGroup: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code


    }
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        label = StrikeThroughText(frame: CGRect.null)


        label.textColor = UIColor.blackColor()
        label.font = UIFont.boldSystemFontOfSize(16)
        label.backgroundColor = UIColor.clearColor()
        func createCueLabel() -> UILabel {
            let label = StrikeThroughText(frame: CGRect.null)
            label.textColor = UIColor.blackColor()
            label.font = UIFont.boldSystemFontOfSize(32.0)
            label.backgroundColor = UIColor.clearColor()
            return label
        }
        
        tickLabel = createCueLabel()
        tickLabel.text = "\u{2713}"
        tickLabel.textAlignment = .Right
        crossLabel = createCueLabel()
        crossLabel.text = "\u{2717}"
        crossLabel.textAlignment = .Left
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        addSubview(label)

        addSubview(tickLabel)
        addSubview(crossLabel)
        // remove the default blue highlight for selected cells
        selectionStyle = .None
        
        // gradient layer for cell
        gradientLayer.frame = bounds
        let color1 = UIColor(white: 1.0, alpha: 0.2).CGColor as CGColorRef
        let color2 = UIColor(white: 1.0, alpha: 0.1).CGColor as CGColorRef
        let color3 = UIColor.clearColor().CGColor as CGColorRef
        let color4 = UIColor(white: 0.0, alpha: 0.1).CGColor as CGColorRef
        gradientLayer.colors = [color1, color2, color3, color4]
        gradientLayer.locations = [0.0, 0.01, 0.95, 1.0]
        layer.insertSublayer(gradientLayer, atIndex: 0)
        
        var recognizer = UIPanGestureRecognizer(target: self, action: "handlePan:")
        recognizer.delegate = self
        addGestureRecognizer(recognizer)
    }
    let kLabelLeftMargin: CGFloat = 15.0
    let kUICuesMargin: CGFloat = 10.0, kUICuesWidth: CGFloat = 50.0
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // ensure the gradient layer occupies the full bounds
        gradientLayer.frame = bounds
        //itemCompleteLayer.frame = bounds
        label.frame = CGRect(x: kLabelLeftMargin, y: 0,
            width: bounds.size.width - kLabelLeftMargin, height: bounds.size.height)
        tickLabel.frame = CGRect(x: -kUICuesWidth - kUICuesMargin, y: 0,
            width: kUICuesWidth, height: bounds.size.height)
        crossLabel.frame = CGRect(x: bounds.size.width + kUICuesMargin, y: 0,
            width: kUICuesWidth, height: bounds.size.height)
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    

    //MARK: - horizontal pan gesture methods
    func handlePan(recognizer: UIPanGestureRecognizer) {
        // 1
        if recognizer.state == .Began {
            // when the gesture begins, record the current center location
            originalCenter = center
        }
        // 2
        if recognizer.state == .Changed {
            let translation = recognizer.translationInView(self)
            center = CGPointMake(originalCenter.x + translation.x, originalCenter.y)
            // has the user dragged the item far enough to initiate a delete/complete?
            deleteOnDragRelease = frame.origin.x < -frame.size.width / 2.0
            completeOnDragRelease = frame.origin.x > frame.size.width / 2.0
            
            let cueAlpha = fabs(frame.origin.x) / (frame.size.width / 2.0)
            tickLabel.alpha = cueAlpha
            crossLabel.alpha = cueAlpha
            // indicate when the user has pulled the item far enough to invoke the given action
            tickLabel.textColor = completeOnDragRelease ? UIColor.greenColor() : UIColor.whiteColor()
            crossLabel.textColor = deleteOnDragRelease ? UIColor.redColor() : UIColor.whiteColor()
        }
        // 3
        if recognizer.state == .Ended {
            // the frame this cell had before user dragged it
            let originalFrame = CGRect(x: 0, y: frame.origin.y,
                width: bounds.size.width, height: bounds.size.height)
            if deleteOnDragRelease {
                if delegate != nil && operationItem != nil {
                    // notify the delegate that this item should be deleted
                    delegate!.toDoItemSink(operationItem!)
                }
            }else if completeOnDragRelease {
                if delegate != nil && operationItem != nil {
                    // notify the delegate that this item should be deleted
                    delegate!.toDoItemFloat(operationItem!)
                }
            } else {
                UIView.animateWithDuration(0.2, animations: {self.frame = originalFrame})
            }
        }
    }
    override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGestureRecognizer = gestureRecognizer as? UIPanGestureRecognizer {
            let translation = panGestureRecognizer.translationInView(superview!)
            if fabs(translation.x) > fabs(translation.y) {
                return true
            }
            return false
        }
        return false
    }
}
