//
//  ContactsCell.swift
//  commontech
//
//  Created by matata on 19/10/2015.
//  Copyright © 2015 matata. All rights reserved.
//

import UIKit

class ContactsCell: UITableViewCell {
    //MARK: cell properties
    @IBOutlet weak var contactImage: UIImageView!
    @IBOutlet weak var contactName: UILabel!
    @IBOutlet weak var contactEmail: UILabel!
    @IBOutlet weak var contactPhone: UILabel!
    @IBOutlet weak var isWevo: UILabel!
    
    @IBOutlet weak var isChatting : UILabel!
    
    func isChattingRepository(){
        
    }
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
