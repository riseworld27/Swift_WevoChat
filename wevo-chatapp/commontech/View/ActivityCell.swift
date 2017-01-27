//
//  ActivityCell.swift
//  commontech
//
//  Custom table view cell for activity item
//
//  Created by Danny Fassler on 1/28/16.
//  Copyright © 2016 commomtech. All rights reserved.
//

import UIKit

class ActivityCell: UITableViewCell {

    // MARK: Properties
    
    @IBOutlet weak var imgItem: UIImageView!
    
    @IBOutlet weak var lblName: UILabel!
    
    @IBOutlet weak var lblInfo: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
