//
//  DetailsInstagram.swift
//  commontech
//
//  Created by matata on 21/10/2015.
//  Copyright © 2015 matata. All rights reserved.
//


import UIKit

class DetailsInstagram: NSObject {
    // MARK: Properties
    var name: String?
    var phone: String?
    var email: String?
    var picture: NSData?
    
    // MARK: init
    init?(name: String, phone: String, email: String, picture: NSData) {
        // Initialize stored properties.
        self.name = name
        self.phone = phone
        self.email = email
        self.picture = picture
        
    }
    
}
