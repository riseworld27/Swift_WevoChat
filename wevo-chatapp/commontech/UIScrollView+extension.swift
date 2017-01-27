//
//  UIScrollView+extension.swift
//  wevo
//
//  Created by Danny Fassler on 2/8/16.
//  Copyright © 2016 matata. All rights reserved.
//

import Foundation

extension UIScrollView {
    
    func isAtTop() -> Bool {
        return (self.contentOffset.y <= self.verticalOffsetForTop())
    }
    
    func verticalOffsetForTop() -> CGFloat {
        let topInset = self.contentInset.top
        return -topInset
    }
    
}
