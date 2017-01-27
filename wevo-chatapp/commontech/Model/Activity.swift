//
//  Activity.swift
//  commontech
//
//  Activity item data model (for testing)
//
//  Created by Danny Fassler on 1/28/16.
//  Copyright © 2016 commomtech. All rights reserved.
//

import Foundation

class Activity {

    enum Status {
        case None, Sinked, Floated
    }
    
    var name: String
    var image: String
    var info: String
    var status: Status

    init?(name: String, image: String, info: String) {
        self.name = name
        self.image = image
        self.info = info
        self.status = Status.None
        
        if name.isEmpty {
            return nil
        }
    }
    
    init(json: NSDictionary) {
        self.name = json["name"] as! String
        self.info = json["info"] as! String
        self.image = json["image"] as! String
        self.status = Status.None
    }
}


