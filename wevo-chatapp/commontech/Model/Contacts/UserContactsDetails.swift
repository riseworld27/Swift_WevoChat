//
//  UserFacebookDetails.swift
//  commontech
//
//  Created by matata on 26/10/2015.
//  Copyright © 2015 matata. All rights reserved.
//
import UIKit

class UserContactsDetails: NSObject {
    // MARK: Properties
    var identifier: String?
    var givenName: String?
    var familyName: String?
    var phoneNumbers: [String]?
    var emailAddresses: [String]?
   // var userImage: NSData?
    
    
    // MARK: init

    init?(identifier: String, givenName: String, familyName: String, phoneNumbers: [String], emailAddresses: [String]){//, userImage: NSData) {
        // Initialize stored properties.
        self.identifier = identifier
        self.givenName = givenName
        self.familyName = familyName
        self.phoneNumbers = phoneNumbers
        self.emailAddresses = emailAddresses
        //self.userImage = userImage
        
    }
    
}
