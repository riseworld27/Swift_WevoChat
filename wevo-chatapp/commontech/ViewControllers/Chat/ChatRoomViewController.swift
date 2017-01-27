//
//  ChatRoomViewController.swift
//  commontech
//
//  Created by Sergey Rashidov on 15/01/16.
//  Copyright © 2016 matata. All rights reserved.
//

import UIKit
import OAuthSwift
import Alamofire

class ChatRoomViewController: UIViewController, UITabBarDelegate {
    @IBOutlet weak var navItem: WevoNavigationBar!
    
    @IBOutlet weak var charRoomTableView: UITableView!
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    var arrayGroup: [Groups] = []
    var arrayConnection: [Connection] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadGroups()
        loadConnection()
        self.initNavBar()
        //self.charRoomTableView.reloadData()
        
    }
    
    override func viewDidAppear(animated: Bool) {
        let indexPath = self.charRoomTableView.indexPathForSelectedRow;
        print("You selected cell #\(indexPath)!")
        
        if (indexPath != nil){
            self.charRoomTableView.deselectRowAtIndexPath(indexPath!, animated: false)
        }
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
    
    func do_table_refresh()
    {
        dispatch_async(dispatch_get_main_queue(), {
            self.charRoomTableView.reloadData()
            self.StopActivity()
            
            return
        })
    }
    
    func initNavBar() {
        self.navItem!.showHomeBtn()
        (self.navItem.rightBarButtonItems![0].customView as! UIButton).addTarget(self, action: "privetAction:", forControlEvents: UIControlEvents.TouchUpInside)
        (self.navItem.rightBarButtonItems![1].customView as! UIButton).addTarget(self, action: "myProfileAction:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    func privetAction(sender:AnyObject) {
        self.showAlertView("Dive", message: "You can go to\"off line\" mode for browsing contacts in private mode")
        
    }
    
    func showAlertView(title: String, message: String) {
        var diveTime = ""
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let firstAction = UIAlertAction(title: "30 min", style: .Default) { (alert: UIAlertAction!) -> Void in
            diveTime = "30"
        }
        let secondAction = UIAlertAction(title: "1 hour", style: .Default) { (alert: UIAlertAction!) -> Void in
            diveTime = "60"
        }
        let threeAction = UIAlertAction(title: "6 hours", style: .Default) { (alert: UIAlertAction!) -> Void in
            diveTime = "360"
        }
        let fourAction = UIAlertAction(title: "24 hours", style: .Default) { (alert: UIAlertAction!) -> Void in
            diveTime = "1440"
        }
        alert.addAction(firstAction)
        alert.addAction(secondAction)
        alert.addAction(threeAction)
        alert.addAction(fourAction)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func myProfileAction(sender:AnyObject) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("vcUserFacebookDetails") as? UserFacebookDetailsViewController
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        if item.tag == 1
        {
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("vcConnectionCollectionViewController") as? ConnectionCollectionViewController
            self.navigationController?.pushViewController(vc!, animated: true)

        }
        else if item.tag == 2{
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("vcCreateGroup") as? CreateGroupController
            self.navigationController?.pushViewController(vc!, animated: true)
        }
        else if item.tag == 3{
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("vcChatViewController") as? ChatViewController
            vc!.passedType = "user"
            self.navigationController?.pushViewController(vc!, animated: true)
 
        }
    }
    
    func loadGroups()
    {
        let defaults = NSUserDefaults.standardUserDefaults()
        let UserId = defaults.stringForKey("guid")
        let headers = ["Authorization": defaults.stringForKey("guid")!]
        
        let postEndpoint = "http://wevoapi.azurewebsites.net:80/api/users/" + UserId! + "/groups"
        Alamofire.request(.GET, postEndpoint, parameters:  nil, headers: headers).responseJSON { response in
            print(response)
            let resultDic : NSDictionary =  (response.result.value as? NSDictionary)!
            
            let totalItems : NSNumber = resultDic.valueForKey("totalItems") as! NSNumber
            if totalItems == 0
            {
                self.StopActivity()
                return
            }
            let resultArr : NSArray =  (resultDic.valueForKey("data") as? NSArray)!
            for item in resultArr {
                let group =  Groups(GroupName: (item.valueForKey("GroupName") as? String)!, GroupId: (item.valueForKey("GroupId") as? String)!, UserId: (item.valueForKey("OwnerUserId") as? String)!)!
                
                self.arrayGroup.append(group)
                
            }
            //self.do_table_refresh();
        }
        
    }
    
    ///
    
    func loadConnection()
    {
        let defaults = NSUserDefaults.standardUserDefaults()
        let UserId = defaults.stringForKey("guid")
        let headers = ["Authorization": defaults.stringForKey("guid")!]
        
        /*
        let postEndpoint = "http://wevoapi.azurewebsites.net:80/api/connection/" + UserId!
        Alamofire.request(.GET, postEndpoint, parameters:  nil, headers: headers).responseJSON { response in
            print(response)
            let resultDic : NSDictionary =  (response.result.value as? NSDictionary)!
            if resultDic.valueForKey("data") === NSNull(){
                let alert = UIAlertController(title: "Error", message: "Data is null", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
                
                self.presentViewController(alert, animated: true, completion: nil)
            }else{
                let resultArr : NSArray =  (resultDic.valueForKey("data") as? NSArray)!
                for item in resultArr {
                    let users =  Connection(
                        id: item.valueForKey("id") === NSNull() ? "": (item.valueForKey("id") as? String)!,
                        type: item.valueForKey("type") === NSNull() ? "": (item.valueForKey("type") as? String)!,
                        name: item.valueForKey("name") === NSNull() ? "": (item.valueForKey("name") as? String)!,
                        image: item.valueForKey("image") === NSNull() ? "": (item.valueForKey("image") as? String)!,
                        phone: item.valueForKey("phone") === NSNull() ? "": (item.valueForKey("phone") as? String)!,
                        selected: false,
                        hightlight: false,
                        imageData: nil
                        )!
                    
                    self.arrayConnection.append(users)
                    
                }
            }
            self.do_table_refresh();
            
        }*/
        
        var isUsers = false
        var isGroups = false
        let postEndpoint = "http://wevoapi.azurewebsites.net:80/api/connection/" + UserId! + "/users"
        Alamofire.request(.GET, postEndpoint, parameters:  nil, headers: headers).responseJSON { response in
            print(response)
            let resultDic : NSDictionary =  (response.result.value as? NSDictionary)!
            if resultDic.valueForKey("data") === NSNull(){
                let alert = UIAlertController(title: "Error", message: "Data is null", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
                
                self.presentViewController(alert, animated: true, completion: nil)
            }else{
                let resultArr : NSArray =  (resultDic.valueForKey("data") as? NSArray)!
                for item in resultArr {
                    let users =  Connection(
                        id: item.valueForKey("id") === NSNull() ? "": (item.valueForKey("id") as? String)!,
                        type: item.valueForKey("type") === NSNull() ? "": (item.valueForKey("type") as? String)!,
                        name: item.valueForKey("name") === NSNull() ? "": (item.valueForKey("name") as? String)!,
                        image: item.valueForKey("image") === NSNull() ? "": (item.valueForKey("image") as? String)!,
                        phone: item.valueForKey("phone") === NSNull() ? "": (item.valueForKey("phone") as? String)!,
                        selected: false,
                        hightlight: false,
                        imageData: NSData()
                        )!
                    
                    self.arrayConnection.append(users)
                }
            }
            isUsers = true
            self.do_table_refresh();
            
            //load phone connection only after users and groups
            //   self.loadContactsPhone()
        }
        let postEndpoint1 = "http://wevoapi.azurewebsites.net:80/api/connection/" + UserId! + "/groups"
        Alamofire.request(.GET, postEndpoint1, parameters:  nil, headers: headers).responseJSON { response in
            print(response)
            let resultDic : NSDictionary =  (response.result.value as? NSDictionary)!
            if resultDic.valueForKey("data") === NSNull(){
                let alert = UIAlertController(title: "Error", message: "Data is null", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
                
                self.presentViewController(alert, animated: true, completion: nil)
            }else{
                let resultArr : NSArray =  (resultDic.valueForKey("data") as? NSArray)!
                for item in resultArr {
                    let users =  Connection(
                        id: item.valueForKey("id") === NSNull() ? "": (item.valueForKey("id") as? String)!,
                        type: item.valueForKey("type") === NSNull() ? "": (item.valueForKey("type") as? String)!,
                        name: item.valueForKey("name") === NSNull() ? "": (item.valueForKey("name") as? String)!,
                        image: item.valueForKey("image") === NSNull() ? "": (item.valueForKey("image") as? String)!,
                        phone: item.valueForKey("phone") === NSNull() ? "": (item.valueForKey("phone") as? String)!,
                        selected: false,
                        hightlight: false,
                        imageData: NSData()
                        )!
                    
                    self.arrayConnection.append(users)
                    
                }
            }
            self.do_table_refresh();
            isGroups = true
            
            
        }

        
    }
    
}

//MARK: - UITableViewDataSource

extension ChatRoomViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return tableView.rowHeight
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayConnection.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let res = tableView.dequeueReusableCellWithIdentifier("ChatRoomTableViewCell", forIndexPath: indexPath) as! ChatRoomTableViewCell
        
        res.lastMessage.text = "this"
        //res.userGroupName.text = arrayGroup[indexPath]!.use
        res.userGroupName.text = self.arrayConnection[indexPath.row].name
        
        //res.userImage
        //self.arrayConnection[indexPath.row].image
        
        let pictureURL = NSURL(string:self.arrayConnection[indexPath.row].image)
        res.userImage.layer.cornerRadius = res.userImage.frame.size.width / 2
        res.userImage.clipsToBounds = true
        
        if let profileImageData = NSData(contentsOfURL: pictureURL!){
            
            res.userImage.image = UIImage(data: profileImageData)
        }
        else{
            res.userImage.image = UIImage(named: Images.ChatAudioPlayerProfile)
        }
        
        return res
    }
}


//MARK: - UITableViewDelegate

extension ChatRoomViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("You selected cell #\(indexPath.row)!")
        let indexPath = tableView.indexPathForSelectedRow;

        let defaults = NSUserDefaults.standardUserDefaults()
        let UserId = defaults.stringForKey("guid")
        let headers = ["Authorization": defaults.stringForKey("guid")!]
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("vcChatViewController") as? ChatViewController
        
        if self.arrayConnection[indexPath!.row].type == "user"
        {
            print(self.arrayConnection[indexPath!.row].id)
            print(UserId!)
            
            if self.arrayConnection[indexPath!.row].id.compare(UserId!) == NSComparisonResult.OrderedDescending{
                vc!.passedChatId = self.arrayConnection[indexPath!.row].id + UserId!
            }else if self.arrayConnection[indexPath!.row].id.compare(UserId!) == NSComparisonResult.OrderedAscending{
                vc!.passedChatId = UserId! + self.arrayConnection[indexPath!.row].id
            }else{
                vc!.passedChatId = self.arrayConnection[indexPath!.row].id + UserId!
            }
            
            vc!.passedFreindId = self.arrayConnection[indexPath!.row].id
            vc!.passedType = self.arrayConnection[indexPath!.row].type
            
            //vc!.getUserChat()
            //vc!.getFriendUserChat()
            
            vc!.otherUserName = self.arrayConnection[indexPath!.row].name
            
            self.navigationController?.pushViewController(vc!, animated: false)
            
        }else if self.arrayConnection[indexPath!.row].type == "group" {//group
            vc!.passedChatId = self.arrayConnection[indexPath!.row].id
            vc!.getGroupChat()

            vc!.passedType = self.arrayConnection[indexPath!.row].type
            
            self.navigationController?.pushViewController(vc!, animated: false)
            
        }else{
            let parametersToSend = [
                //  "Guid": (Guid as? AnyObject)!,
                "stringValue": self.arrayConnection[indexPath!.row].id!
            ]
            let postEndpoint = "http://wevoapi.azurewebsites.net:80/api/chat/" + UserId!
            
            Alamofire.request(.POST, postEndpoint, parameters:  parametersToSend, headers: headers).responseJSON { response in
                print(response)
                let resultDic : NSDictionary =  (response.result.value as? NSDictionary)!
                if resultDic.valueForKey("data") === NSNull(){
                    let alert = UIAlertController(title: "Error", message: "Data is null", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
                    
                    self.presentViewController(alert, animated: true, completion: nil)
                }else{
                    
                    
                    // let defaults = NSUserDefaults.standardUserDefaults()
                    // let Userkey = defaults.stringForKey("guid")
                    let vc = self.storyboard?.instantiateViewControllerWithIdentifier("vcChatViewController") as? ChatViewController
                    if self.arrayConnection[indexPath!.row].type == "user"
                    {
                        vc!.passedChatId = resultDic.valueForKey("data")! as! String
                        vc!.passedFreindId = self.arrayConnection[indexPath!.row].id
                        
                    }
                    vc!.passedType = self.arrayConnection[indexPath!.row].type
                    self.StopActivity()
                    self.navigationController?.pushViewController(vc!, animated: false)
                }
            }
        }
    }
}

