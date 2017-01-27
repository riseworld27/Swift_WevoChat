//
//  ChatRoomTableViewCell.swift
//  commontech
//
//  Created by Sergey Rashidov on 15/01/16.
//  Copyright © 2016 matata. All rights reserved.
//

import UIKit
import OAuthSwift
import Alamofire

class ChatRoomTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var lastMessage: UILabel!
    @IBOutlet weak var userGroupName: UILabel!
    @IBOutlet weak var messageCount: UILabel!
}
