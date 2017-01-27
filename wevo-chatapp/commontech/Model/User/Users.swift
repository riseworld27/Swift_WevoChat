//
//  Users.swift
//  commontech
//
//  Created by matata on 12/01/2016.
//  Copyright © 2016 matata. All rights reserved.
//

import Foundation
import UIKit

class Users: NSObject {
    
    var userId: String!
    var userName: String!
    var userImage: String!
    var userPhone: String!
    
    
    init?(userId: String, userName: String, userImage: String, userPhone: String ) {
        // Initialize stored properties.
        self.userId = userId
        self.userName = userName
        self.userImage = userImage
        self.userPhone = userPhone
        
        
    }
}
class Connection: NSObject {
    
    var id: String!
    var type: String!
    var name: String!
    var image: String!
    var phone: String!
    var selected: Bool!
    var hightlight: Bool!
    var imageData: NSData!

    
    init?(id: String, type: String, name: String, image: String, phone: String , selected: Bool, hightlight: Bool, imageData: NSData! ) {
        // Initialize stored properties.
        self.id = id
        self.type = type
        self.name = name
        self.image = image
        self.phone = phone
        self.selected = selected
        self.hightlight = hightlight
        self.imageData = imageData

        
    }
}
