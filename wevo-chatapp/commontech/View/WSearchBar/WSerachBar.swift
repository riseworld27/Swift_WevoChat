//
//  WSerachBar.swift
//  wevo
//
//  Created by matata on 12/1/15.
//

import UIKit

class WSerachBar: UIView {

    @IBOutlet weak var searchBar: UISearchBar!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        self.searchBar.frame = CGRect(x:0, y: 0, width: UIScreen.mainScreen().bounds.width, height: self.searchBar.frame.size.height)
        self.frame = CGRect(x:0, y: 0, width: UIScreen.mainScreen().bounds.width, height: self.frame.size.height)
        
    }

}
