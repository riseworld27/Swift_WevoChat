//
//  User.swift
//  commontech
//
//  Created by matata on 12/19/15.
//  Copyright © 2015 matata. All rights reserved.
//

import Foundation
import UIKit

class User: NSObject {
    
    var userId : String!
    var userName: String!
    var userImage: String!
    
    func initWithDefaults() {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        self.userId = defaults.stringForKey("UserId")
    }

    
    func initWithDic(dictionary : Dictionary<String, AnyObject>) {
        
        self.userId = dictionary["userId"]! as! String
        self.userName = dictionary["userName"]! as! String
        
    }
}
