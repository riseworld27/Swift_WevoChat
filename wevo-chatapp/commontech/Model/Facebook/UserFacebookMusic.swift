//
//  UserFacebookMusic.swift
//  commontech
//
//  Created by matata on 19/11/2015.
//  Copyright © 2015 matata. All rights reserved.
//

import UIKit
class UserFacebookMusic: NSObject {
    // MARK: Properties
    var name: String
    var musicId: String
    var userkey: String
    var userUDID: String
    var created_time: String
    
    
    init?(name: String,musicId: String,userkey: String ,userUDID: String ,created_time: String) {
        // Initialize stored properties.
        self.name = name
        self.musicId = musicId
        self.userkey = userkey
        self.userUDID = userUDID
        self.created_time = created_time
        
    }
    
}
