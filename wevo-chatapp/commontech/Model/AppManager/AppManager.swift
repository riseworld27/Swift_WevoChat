//
//  AppManager.swift
//  commontech
//
//  Created by matata on 12/19/15.
//  Copyright © 2015 matata. All rights reserved.
//

import UIKit

class AppManager: NSObject {
    
    static var sharedInstance : AppManager!
    var currentUser : User!
    
    static func appManagerSharedInstance() -> AppManager {
        objc_sync_enter(self)
        if sharedInstance == nil {
            
            sharedInstance = AppManager()
            sharedInstance.initialize()
        }
        objc_sync_exit(self)

        return sharedInstance
    }
    
    func synced(lock: AppManager, closure: () -> ()) {
        objc_sync_enter(lock)
        closure()
        objc_sync_exit(lock)
    }
    
    func initialize() {
        
        currentUser = User()
        currentUser.initWithDefaults()
    }

}
