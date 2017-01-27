//
//  InstagramCells.swift
//  commontech
//
//  Created by matata on 21/10/2015.
//  Copyright © 2015 matata. All rights reserved.
//

import UIKit
class InstagramCells: UITableViewCell {
    
    @IBOutlet weak var lblImage: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    
  //  @IBOutlet weak var lblEmail: UILabel!
  //  @IBOutlet weak var lblPhone: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
