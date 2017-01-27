//
//  GroupsCell.swift
//  commontech
//
//  Created by matata on 09/11/2015.
//  Copyright © 2015 matata. All rights reserved.
//

import UIKit

class GroupsCell: UITableViewCell {
    @IBOutlet weak var lblName: UILabel!

    @IBOutlet weak var viewMembersGroup: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
