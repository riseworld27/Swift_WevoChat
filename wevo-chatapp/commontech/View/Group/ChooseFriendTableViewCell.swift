//
//  ChooseFriendTableViewCell.swift
//  commontech
//
//  Created by matata on 17/11/2015.
//  Copyright © 2015 matata. All rights reserved.
//

import UIKit




class ChooseFriendTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var photoImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
