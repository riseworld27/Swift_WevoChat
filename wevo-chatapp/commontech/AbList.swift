//
//  AbList.swift
//  commontech
//
//  Created by matata on 19/10/2015.
//  Copyright © 2015 matata. All rights reserved.
//

import UIKit

class AbList: NSObject {
    // MARK: Properties
    var name: String?
    var phone: String?
    var email: String?
    var picture: NSData?
    
    init?(name: String, phone: String, email: String, picture: NSData) {
        // Initialize stored properties.
        self.name = name
        self.phone = ""
        self.email = ""
        self.picture = picture

        
        
        
    }


    
//    init?(name: String, phone: String, email: String,picture: NSData ) {
//        // Initialize stored properties.
//        self.name = name
//        self.phone = phone
//        self.email = email
//        self.picture = picture
//
//
//        
//    }
    
}
