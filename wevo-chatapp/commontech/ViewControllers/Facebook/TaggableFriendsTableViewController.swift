//
//  TaggableFriendsTableViewController.swift
//  commontech
//
//  Created by matata on 15/10/2015.
//  Copyright © 2015 matata. All rights reserved.
//

import UIKit
import Alamofire
class TaggableFriendsTableViewController: UIViewController {
    
//    // MARK: screen Properties
    @IBOutlet var tblTaggableFriends: UITableView!
    @IBOutlet weak var activity: UIActivityIndicatorView!

    // MARK: Properties
    var taggableFriends = [Friends]()
    @IBAction func goHome(sender: AnyObject) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("vcConnectionCollectionViewController") as? ConnectionCollectionViewController
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    // MARK: override function
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

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
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated:true);

        let defaults = NSUserDefaults.standardUserDefaults()
      //  let UserId = defaults.stringForKey("UserId")

        self.StartActivity()
   
        
       // let postEndpoint = "http://wevoapi.azurewebsites.net:80/api/Groups/Members"
        let postEndpoint = "http://wevoapi.azurewebsites.net:80/api/users/" + defaults.stringForKey("guid")! + "/friends"

        
        let headers = ["Authorization": defaults.stringForKey("guid")!]

        Alamofire.request(.GET, postEndpoint, parameters:  nil, headers: headers).responseJSON { response in
            print(response)
            let resultDic : NSDictionary =  (response.result.value as? NSDictionary)!

            let resultArr : NSArray =  (resultDic.valueForKey("data") as? NSArray)!
            for item in resultArr {
                let tagfriend = Friends(userId: (item.valueForKey("userId") as? String)!,
                    facebookId: (item.valueForKey("facebookId")as? String)!,
                    Name: (item.valueForKey("Name")as? String)!,
                    FirstName: (item.valueForKey("FirstName")as? String)!,
                    LastName: (item.valueForKey("LastName")as? String)!,
                    Email: item.valueForKey("Email") === NSNull() ? "": (item.valueForKey("Email")as? String)!,
                    Picture: (item.valueForKey("Picture")as? String)!,
                    UpdatedTime: (item.valueForKey("UpdatedTime")as? String)!)!
                self.taggableFriends.append(tagfriend)
                
            }
            self.StopActivity()

            self.do_table_refresh();
            
            

            }
 
        

    }
    func do_table_refresh()
    {
        dispatch_async(dispatch_get_main_queue(), {
            self.tblTaggableFriends.reloadData()
            self.StopActivity()
            return
        })
    }



}
//MARK: - UITableViewDataSource

extension TaggableFriendsTableViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.taggableFriends.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "FriendTableViewCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! FriendTableViewCell
        
        let taggableFriend = self.taggableFriends[indexPath.row]
        if let label = cell.nameLabel{
            label.text = taggableFriend.Name
        }
        if let url = cell.photoImage{
            let pictureURL = NSURL(string:taggableFriend.Picture)

            if let data = NSData(contentsOfURL: pictureURL!){
                url.contentMode = UIViewContentMode.ScaleAspectFit
                url.image = UIImage(data: data)
            }
        }
        
        
        return cell
    }
}
