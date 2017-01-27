//
//  GroupsController.swift
//  commontech
//
//  Created by matata on 09/11/2015.
//  Copyright © 2015 matata. All rights reserved.
//

import UIKit
import OAuthSwift
import Alamofire

class GroupsController: UIViewController, UITabBarDelegate {
    @IBOutlet weak var navItem: WevoNavigationBar!

    @IBOutlet weak var goToGroupsTable: UIButton!
    @IBOutlet weak var myGroups: UIButton!
    @IBOutlet weak var contactsBtn: UIButton!
    @IBOutlet weak var createGroupIcon: UITabBarItem!
    @IBOutlet weak var searchIcon: UITabBarItem!
    @IBOutlet weak var goChatIcon: UITabBarItem!
    @IBOutlet weak var tabBar: UITabBar!

    @IBOutlet var firstViewController: UIView!
    //Lifecycle method
    
    override func viewDidLoad() {
        super.viewDidLoad()

        contactsBtn.hidden = true
        self.tabBar.tintColor = UIColor.whiteColor()
        self.tabBar.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.tabBar.layer.shadowOpacity = 0.7
        self.tabBar.layer.shadowRadius = 15

        myGroups.backgroundColor = UIColor.cyanColor()

        self.tabBar.tintColor = UIColor.whiteColor()
        
        let tabBarItem1 = tabBar.items![0] as UITabBarItem
        let tabBarItem2 = tabBar.items![1] as UITabBarItem
        let tabBarItem3 = tabBar.items![2] as UITabBarItem

        tabBarItem1.selectedImage = UIImage(named: "wevo_chat_massages")?.imageWithRenderingMode(.AlwaysOriginal)
        tabBarItem2.selectedImage = UIImage(named: "wevo_icon_create_group")?.imageWithRenderingMode(.AlwaysOriginal)
        tabBarItem3.selectedImage = UIImage(named: "wevo_icon_search")?.imageWithRenderingMode(.AlwaysOriginal)

        for item in self.tabBar.items! as [UITabBarItem] {
            if let image = item.image {
                item.image = image.imageWithColor(UIColor.whiteColor()).imageWithRenderingMode(.AlwaysOriginal)

            }
        }

        self.initNavBar()
    }
    func initNavBar() {
        self.navItem!.showHomeBtn()
        (self.navItem.rightBarButtonItems![0].customView as! UIButton).addTarget(self, action: "privetAction:", forControlEvents: UIControlEvents.TouchUpInside)
        (self.navItem.rightBarButtonItems![1].customView as! UIButton).addTarget(self, action: "myProfileAction:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    func privetAction(sender:AnyObject) {
        self.showAlertView("Dive", message: "You can go to\"off line\" mode for browsing contacts in private mode")
        
    }
    func myProfileAction(sender:AnyObject) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("vcUserFacebookDetails") as? UserFacebookDetailsViewController
        self.navigationController?.pushViewController(vc!, animated: true)
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
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func removeFbData() {
        
        FBSDKAccessToken.setCurrentAccessToken(nil)
    }
    
    //Action methods
    
    @IBAction func logoutFB(sender: AnyObject) {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        //defaults.setObject(nil, forKey: "UserId")
        defaults.setObject(nil, forKey: "phoneNumber")
        defaults.setObject(nil, forKey: "guid")
        
        defaults.setObject("false", forKey: "isGoogleUser")
        defaults.setObject("false", forKey: "isFacebookUser")
        defaults.setObject("false", forKey: "isInstagramUser")
        defaults.setObject("false", forKey: "isYoutubeUser")
        defaults.setObject("false", forKey: "isContacts")

        removeFbData()
        //send to choose social network to connect with
        
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("vcEnterPhone") as? EnterPhoneController
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    @IBAction func gotoConnections(sender: AnyObject) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("vcConnectionCollectionViewController") as? ConnectionCollectionViewController
        self.navigationController?.pushViewController(vc!, animated: true)
        
    }
    @IBAction func gotoContacts(sender: AnyObject) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("vcContacts") as? ContactsTableViewController
        self.navigationController?.pushViewController(vc!, animated: true)
        
    }
    @IBAction func gotoConnectMoreSocial(sender: AnyObject) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("vcChooseSocial") as? ChooseSocialViewController
        self.navigationController?.pushViewController(vc!, animated: true)
    }

    @IBAction func goToGroupList(sender: AnyObject) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("vcGroupsTable") as? GroupsTableViewController
        self.navigationController?.pushViewController(vc!, animated: true)
        
    }
    
  
    @IBAction func gotoSync(sender: AnyObject) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("vcSyncPhoneContactsViewController") as? SyncPhoneContactsViewController
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @IBAction func goHome(sender: AnyObject) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("vcConnectionCollectionViewController") as? ConnectionCollectionViewController
        self.navigationController?.pushViewController(vc!, animated: true)
    }
 
   
    
    @IBAction func gotoData(sender: AnyObject) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("vcUserData") as? UserDataViewController
        self.navigationController?.pushViewController(vc!, animated: true)
        
    }
    
    @IBAction func gotoFriends(sender: AnyObject) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("FriendTableViewCell") as? TaggableFriendsTableViewController
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        if item.tag == 1
        {
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("vcChatRoomViewController") as? ChatRoomViewController
            self.navigationController?.pushViewController(vc!, animated: true)
        }
        else if item.tag == 2{
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("vcCreateGroup") as? CreateGroupController
            self.navigationController?.pushViewController(vc!, animated: true)
        }
        else if item.tag == 3{
      
        }
    }
    @IBAction func UpdateSocialInfo(sender: AnyObject) {
        let oauthswift = OAuth2Swift(
            consumerKey:    GoogleYoutube["consumerKey"]!,
            consumerSecret: GoogleYoutube["consumerSecret"]!,
            authorizeUrl:   "https://accounts.google.com/o/oauth2/auth",
            accessTokenUrl: "https://accounts.google.com/o/oauth2/token",
            responseType:   "code"
        )
        let defaults = NSUserDefaults.standardUserDefaults()
        let isFacebook = defaults.stringForKey("isFacebookUser")
        let isGoogle = defaults.stringForKey("isGoogleUser")
        let isYoutube = defaults.stringForKey("isYoutubeUser")
        let isInstagram = defaults.stringForKey("isInstagramUser")

//        facebookToken //  FBSDKAccessToken.currentAccessToken().tokenString
//        instagramToken//????
//        youtubeToken//call refresh method and then
//        googleToken////call refresh method and then
        let parametersToSendGoogle : Dictionary<String, AnyObject> = [
            "client_id": GoogleYoutube["consumerKey"]!,
            "client_secret": GoogleYoutube["consumerSecret"]!,
            "refresh_token": defaults.valueForKey("googleRefreshToken")!,
            "grant_type": "refresh_token"
        ]
        oauthswift.client.post("https://www.googleapis.com/oauth2/v4/token", parameters: parametersToSendGoogle, success: { (data, response) -> Void in
            print("Success")
            if let str = NSString(data: data, encoding: NSUTF8StringEncoding) as? String {
                print(str)
                let result = self.convertStringToDictionary(str)
                defaults.setObject(result?["access_token"], forKey: "googleToken")
                
                
            } else {
                print("not a valid UTF-8 sequence")
            }
            }, failure: { (error) -> Void in
                print("Failed")
        })
        let parametersToSendYoutube : Dictionary<String, AnyObject> = [
            "client_id": GoogleYoutube["consumerKey"]!,
            "client_secret": GoogleYoutube["consumerSecret"]!,
            "refresh_token": defaults.valueForKey("youtubeRefreshToken")!,
            "grant_type": "refresh_token"
        ]
        //refresh check
        oauthswift.client.post("https://www.googleapis.com/oauth2/v4/token", parameters: parametersToSendYoutube, success: { (data, response) -> Void in
            print("Success")
            if let str = NSString(data: data, encoding: NSUTF8StringEncoding) as? String {
                print(str)
                let result = self.convertStringToDictionary(str)
                defaults.setObject(result?["access_token"], forKey: "youtubeToken")
                print(defaults.valueForKey("youtubeToken"))
                
            } else {
                print("not a valid UTF-8 sequence")
            }
            }, failure: { (error) -> Void in
                print("Failed")
        })
        
        let parametersToSend = [
            "isContacts": defaults.stringForKey("guid")!,
            "isFacebook": defaults.stringForKey("facebookToken")!,
            "isInstagram": defaults.stringForKey("instagramToken")!,
            "isGoogle": defaults.stringForKey("googleToken")!,
            "isYoutube": defaults.stringForKey("youtubeToken")!

        ]
        
        let postUrl = "http://wevoapi.azurewebsites.net:80/api/users/"+defaults.stringForKey("guid")!+"/savecontactsDetails/"
        Alamofire.request(.POST, postUrl, parameters: parametersToSend).responseJSON { response in
            print(response)
            //let resultDic : NSDictionary =  (response.result.value as? NSDictionary)!
            
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("vcConnectionCollectionViewController") as? ConnectionCollectionViewController
            self.navigationController?.pushViewController(vc!, animated: true)
        }


    }
    func convertStringToDictionary(text: String) -> [String:AnyObject]? {
        if let data = text.dataUsingEncoding(NSUTF8StringEncoding) {
            do {
                let json = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? [String:AnyObject]
                return json
            } catch {
                print("Something went wrong")
            }
        }
        return nil
    }
}
/*extension UIImage {
    func imageWithColor(tintColor: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        
        let context = UIGraphicsGetCurrentContext()! as CGContextRef
        CGContextTranslateCTM(context, 0, self.size.height)
        CGContextScaleCTM(context, 1.0, -1.0);
       // CGContextSetBlendMode(context, kCGBlendModeNormal)//kCGBlendModeNormal
       // CGContextSetBlendMode(context, kCGBlendModeNormal)
        let rect = CGRectMake(0, 0, self.size.width, self.size.height) as CGRect
        CGContextClipToMask(context, rect, self.CGImage)
        tintColor.setFill()
        CGContextFillRect(context, rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext() as UIImage
        UIGraphicsEndImageContext()
        
        return newImage
    }
} */
