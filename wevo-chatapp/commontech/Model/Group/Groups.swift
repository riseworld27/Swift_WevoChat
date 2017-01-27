//
//  Groups.swift
//  commontech
//
//  Created by matata on 25/11/2015.
//  Copyright © 2015 matata. All rights reserved.
//

import Foundation
import UIKit

class Groups: NSObject {
    // MARK: Properties
    var GroupName: String
    var GroupId: String
    var UserId: String
    
    init?(GroupName: String,GroupId: String,UserId: String ) {
        // Initialize stored properties.
        self.GroupName = GroupName
        self.GroupId = GroupId
        self.UserId = UserId
        
    }
    
}
