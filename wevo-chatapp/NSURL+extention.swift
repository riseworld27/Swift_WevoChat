//
//  NSURL+extention.swift
//  commontech
//
//  Created by matata on 21/10/2015.
//  Copyright © 2015 matata. All rights reserved.
//

import Foundation
extension NSURL {
    func getKeyVals() -> Dictionary<String, String>? {
        var results = [String:String]()
        let keyValues = self.query?.componentsSeparatedByString("&")
        if keyValues?.count > 0 {
            for pair in keyValues! {
                let kv = pair.componentsSeparatedByString("=")
                if kv.count > 1 {
                    results.updateValue(kv[1], forKey: kv[0])
                }
            }
            
        }
        return results
    }
}
