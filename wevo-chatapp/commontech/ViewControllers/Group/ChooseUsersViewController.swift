//
//  ChooseUsersViewController.swift
//  commontech
//
//  Created by matata on 17/11/2015.
//  Copyright © 2015 matata. All rights reserved.
//

import UIKit
import Alamofire
class ChooseUsersViewController: UIViewController {
    
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

    // MARK: value from other cv
    var passedValue: String!
    var isViewMembersGroup:Bool!
    // MARK: Properties
    var taggableFriends = [Friends]()

    var taggableFriendsChecked = [Friends]()

    var isView:Bool = true

    @IBOutlet var tblChooseTaggableFriends: UITableView!
    @IBAction func saveMarkItems(sender: AnyObject) {
        self.printSelectedItems()
    }
    // MARK: global Properties
    var saveSelectedUsers: [Friends] = []

    // MARK: override functions

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.StartActivity()
        //TODO : get info from server for users to select and if users in group allready exiest show checkmark
 
        let defaults = NSUserDefaults.standardUserDefaults()
        if (isViewMembersGroup != nil){
        
            if let isMemberGroup = isViewMembersGroup{
                if isMemberGroup{
                    let headers = ["Authorization": defaults.stringForKey("guid")!]
                    Alamofire.request(.GET, "http://wevoapi.azurewebsites.net:80/api/groups/" + passedValue + "/members", parameters: nil, headers: headers).responseJSON { response in
                        print(response)
                        let resultDic : NSDictionary =  (response.result.value as? NSDictionary)!

                        let resultArr : NSArray =  (resultDic.valueForKey("data") as? NSArray)!
                        for item in resultArr {
                            if item is NSNull {
                                
                            }
                            else{
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

                            
                        }
                        self.do_table_refresh();
                        
                    }
                }
                else{
                    self.isView = false
                    let headers = ["Authorization": defaults.stringForKey("guid")!]
                    //

                    Alamofire.request(.GET, "http://wevoapi.azurewebsites.net:80/api/users/" + defaults.stringForKey("guid")! + "/friends", parameters: nil, headers: headers).responseJSON { response in
                        print(response)
                        let resultDic : NSDictionary =  (response.result.value as? NSDictionary)!

                        let resultArr : NSArray =  (resultDic.valueForKey("data") as? NSArray)!
                        for item in resultArr {
                            if item is NSNull {
                            }
                            else{
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

                            
                        }
                        self.do_table_refresh();
                        let rightAddBarButtonItem:UIBarButtonItem = UIBarButtonItem(title: "Save", style: .Plain, target: self, action: "addTapped:")
                        self.navigationItem.setRightBarButtonItems([rightAddBarButtonItem], animated: true)

                    }
                }
            }
            
        }

    }
    func do_table_refresh()
    {
        dispatch_async(dispatch_get_main_queue(), {
            self.tblChooseTaggableFriends.reloadData()
            self.StopActivity()
            return
        })
    }
    func addTapped (sender:UIButton) {
        self.printSelectedItems()
        self.saveListToDB()
    }
}

//MARK: - UITableViewDataSource

extension ChooseUsersViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int  {
        return taggableFriends.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "ChooseFriendTableViewCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ChooseFriendTableViewCell
        
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
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return self.isView == false ? false : true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            let itemUser = self.taggableFriends[indexPath.row]
            let parametersToSend = [
                "stringValue": itemUser.facebookId
                
            ]
            let defaults = NSUserDefaults.standardUserDefaults()
//api/groups/{groupid}/member/{userid}
            let postEndpoint = "http://wevoapi.azurewebsites.net:80/api/groups/" + passedValue + "/member/"+itemUser.facebookId
            let headers = ["Authorization": defaults.stringForKey("guid")!]

            Alamofire.request(.DELETE, postEndpoint, parameters: parametersToSend, headers: headers).responseJSON { response in
                print(response)
            }
            self.taggableFriends.removeAtIndex(indexPath.row)

            self.do_table_refresh()
        }
    }
}
//MARK: - UITableViewDelegate

extension ChooseUsersViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if !self.isView{
            if let cell = tableView.cellForRowAtIndexPath(indexPath) {
                
                if cell.accessoryType == .Checkmark
                {
                    cell.accessoryType = .None
                }
                else
                {
                    cell.accessoryType = .Checkmark
                }
            }
        }
   
    }
    func printSelectedItems() {
        for i in 0...self.tblChooseTaggableFriends.numberOfSections-1
        {
            for j in 0...self.tblChooseTaggableFriends.numberOfRowsInSection(i)-1
            {
                if let cell = self.tblChooseTaggableFriends.cellForRowAtIndexPath(NSIndexPath(forRow: j, inSection: i)) {
                    
                    
                    if cell.accessoryType == .Checkmark
                    {
                        self.saveSelectedUsers.append(self.taggableFriends[j])
                        print(self.saveSelectedUsers)
                    }
                    
                }
                
            }
        }
    }

    func saveListToDB()
    {
       // self.activityIndicator.startAnimating()
        let defaults = NSUserDefaults.standardUserDefaults()

        for(var i = 0 ; i < self.saveSelectedUsers.count; i++){
            let parametersToSend = [
                "stringValue": passedValue
                
            ]
//self.saveSelectedUsers[i].userId
            let postEndpoint = "http://wevoapi.azurewebsites.net:80/api/users/" + self.saveSelectedUsers[i].facebookId + "/addtogroup"
            let headers = ["Authorization": defaults.stringForKey("guid")!]

            Alamofire.request(.POST, postEndpoint, parameters: parametersToSend, headers: headers).responseJSON { response in
                print(response)

            }
            
        }
        if let navController = self.navigationController {
            navController.popViewControllerAnimated(true)
        }

       // self.activityIndicator.stopAnimating()

    }
    
    
}




