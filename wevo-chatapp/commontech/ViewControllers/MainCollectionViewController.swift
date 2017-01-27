//
//  MainCollectionViewController.swift
//  commontech
//
//  Created by matata on 17/01/2016.
//  Copyright © 2016 matata. All rights reserved.
//

import UIKit
import Alamofire
class MainCollectionViewController: UIViewController {
    @IBOutlet weak var activity: UIActivityIndicatorView!
    func StartActivity()
    {
        activity.hidden = false
        activity.startAnimating()
    }
    func StopActivity()
    {
        activity.hidden = true
        activity.stopAnimating()
    }
    @IBOutlet weak var collectionView: UICollectionView!
    let identifier = "UserCollectionCell"
    var arrrayUser: [Users] = []
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var navItem: WevoNavigationBar!

}
extension MainCollectionViewController : UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrrayUser.count
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier,forIndexPath:indexPath) as! UserCell
        let users = self.arrrayUser[indexPath.row]
        if let label = cell.name{
            label.text = users.userName
        }
        if let url = cell.photoImage{
            let pictureURL = NSURL(string:users.userImage)
            
            if let data = NSData(contentsOfURL: pictureURL!){
                url.contentMode = UIViewContentMode.ScaleAspectFit
                url.image = UIImage(data: data)
                
            }
        }
        cell.cornerViewCOntainer.layer.cornerRadius = cell.cornerViewCOntainer.frame.size.width / 2
        cell.cornerViewCOntainer.clipsToBounds = true
        
        return cell
        
    }
}
extension MainCollectionViewController : UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
    }
}
