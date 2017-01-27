//
//  TaggableFriends.swift
//  commontech
//
//  Created by matata on 16/10/2015.
//  Copyright © 2015 matata. All rights reserved.
//

import UIKit

class Friends: NSObject {
    // MARK: Properties
    var userId: String
    var facebookId: String
    var Name: String
    var FirstName: String
    var LastName: String
    var Email: String
    var Picture: String
    var UpdatedTime: String
    
    
    init?(userId: String, facebookId: String, Name: String, FirstName: String, LastName: String, Email: String, Picture: String, UpdatedTime: String) {
        // Initialize stored properties.
        self.userId = userId
        self.facebookId = facebookId
        self.Name = Name
        self.FirstName = FirstName
        self.LastName = LastName
        self.Email = Email
        self.Picture = Picture
        self.UpdatedTime = UpdatedTime
        
    }
    
}
class InstagramFriends: NSObject {
    // MARK: Properties
    var Id: String
    var Name: String
    var Picture: NSURL
    init?(Id: String, Name: String,  Picture: NSURL) {
        // Initialize stored properties.
        self.Id = Id
        self.Name = Name
        self.Picture = Picture
        
    }
}
class InstagramFeed: NSObject {
    // MARK: Properties
    var id: String
    var picture: NSURL
    var created_time : String
    var full_name : String
    var username : String
    var captionId : String
    var text: String
    init?(created_time:String, username: String,id: String,picture: NSURL, full_name:String, captionId:String, text:String) {
        // Initialize stored properties.
        self.created_time = created_time
        self.id = id
        self.picture = picture
        self.full_name = full_name
        self.username = username
        self.captionId = captionId
        self.text = text
        
    }
    
}
