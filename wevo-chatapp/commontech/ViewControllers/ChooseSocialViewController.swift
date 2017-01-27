//
//  ViewController.swift
//  commontech
//
//  Created by matata on 07/10/2015.
//  Copyright © 2015 matata. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import ParseFacebookUtilsV4
import Contacts
import ContactsUI
import Alamofire

class ChooseSocialViewController: UIViewController {
    
    @IBOutlet weak var navItem: WevoNavigationBar!
    
    @IBOutlet weak var taBar: UITabBar!

    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var instagramConnectBtn: UIButton!
    @IBOutlet weak var facebookConnectBtn: UIButton!
    @IBOutlet weak var googleConnectBtn: UIButton!
    
    var contacts: [CNContact] = []
    var userContactsDetails = [UserContactsDetails]()

    //Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        self.checkIfAllreadyConnectSocialNetwork()

        self.navigationController?.navigationBarHidden = true
        
        // instagramConnectBtn.hidden = true
        activity.hidden = true
        // self.initNavBar()


    }
    //Initialize back button on navigtion bar
    func initNavBar() {
        
        self.navItem!.showBackLeftBtn()
        (self.navItem.leftBarButtonItem?.customView as! UIButton).addTarget(self, action: "backAction:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    func backAction(sender:AnyObject) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("vcConnectionCollectionViewController") as? ConnectionCollectionViewController
        self.navigationController?.pushViewController(vc!, animated: true)

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //Private methods
    func loadContactsList(){
        self.findContacts()

    }
    func findContacts()-> [CNContact]{
        
        let keysToFetch = [CNContactFormatter.descriptorForRequiredKeysForStyle(.FullName),CNContactGivenNameKey, CNContactFamilyNameKey, CNContactBirthdayKey, CNContactViewController.descriptorForRequiredKeys()] //
        let fetchRequest = CNContactFetchRequest( keysToFetch: keysToFetch)
        
        let contacts = [CNContact]()
        CNContact.localizedStringForKey(CNLabelPhoneNumberiPhone)
        fetchRequest.mutableObjects = false
        fetchRequest.unifyResults = true
        fetchRequest.sortOrder = .UserDefault
        
        let contactStoreID = CNContactStore().defaultContainerIdentifier()
        print("\(contactStoreID)")
        
        
        do {
            
            try CNContactStore().enumerateContactsWithFetchRequest(fetchRequest) { (let contact, let stop) -> Void in
                /////////////////////////
                if contact.phoneNumbers.count > 0 {
                    
                    self.contacts.append(contact)
                    
                }
                
            }
        } catch let e as NSError {
            print(e.localizedDescription)
        }
        
        return contacts
    }
    func preperContactDetailsToDB()
    {
        for contact in self.contacts{
            var phoneArr: [String] = []
            for phone in contact.phoneNumbers{
                let a = phone.value as! CNPhoneNumber
                let aString : String = a.stringValue
      

                phoneArr.append(aString)
            }
            var emailArr: [String] = []
            for email in contact.emailAddresses{
                emailArr.append(email.value as! String)
            }
            let userContact =  UserContactsDetails(identifier: contact.identifier, givenName: contact.givenName, familyName: contact.familyName, phoneNumbers: phoneArr, emailAddresses: emailArr)!
            
            self.userContactsDetails.append(userContact)
            
            
        }
        insertContactsToDB()
        
    }
    func insertContactsToDB(){
        let defaults = NSUserDefaults.standardUserDefaults()
        let Userkey = defaults.stringForKey("guid")
        if Userkey == nil{
            return
        }
        activity.hidden = false
        activity.startAnimating()
        for(var i = 0; i < self.userContactsDetails.count;i++){
          //  sleep(0.2)
//            if self.userContactsDetails[i].familyName == "Marshall"{
//                for(var j = 0 ; j < self.userContactsDetails[i].phoneNumbers!.count ; j++){
//                    let maskCharSet = NSCharacterSet(charactersInString: " ()-.")
//                    let phoneNumber = self.userContactsDetails[i].phoneNumbers![j]
//                    let cleanedString = phoneNumber.componentsSeparatedByCharactersInSet(maskCharSet).reduce("", combine: +)
//                    print(cleanedString)
//                    
//                    print(self.userContactsDetails[i].phoneNumbers![j].exclude("-"))
//                    print(self.userContactsDetails[i].phoneNumbers![j].replaceAll("-", with: "+"))
//                }
//
//                
//            }
            
            let parametersToSend = [
                "identifier": (self.userContactsDetails[i].identifier as? AnyObject)!,
                "givenName": (self.userContactsDetails[i].givenName as? AnyObject)!,
                "familyName": (self.userContactsDetails[i].familyName as? AnyObject)!,
                "phoneNumbers": (self.userContactsDetails[i].phoneNumbers as? AnyObject)!,
                "emailAddresses": (self.userContactsDetails[i].emailAddresses as? AnyObject)!,
                
            ]
            print(i)
            print(self.userContactsDetails[i].identifier)
            print(self.userContactsDetails[i].givenName)
            print(self.userContactsDetails[i].familyName)
            print(self.userContactsDetails[i].phoneNumbers)
            print(self.userContactsDetails[i].emailAddresses)

            let headers = ["Authorization": defaults.stringForKey("guid")!]
            
            Alamofire.request(.POST, "http://wevoapi.azurewebsites.net:80/api/users/"+defaults.stringForKey("guid")!+"/savecontactsDetails" , parameters:  parametersToSend, headers: headers).responseJSON { response in
                print(response)
                
            }
        }
        
        activity.hidden = true
        activity.stopAnimating()
        defaults.setObject("true", forKey: "isContacts")
        
    }
    func checkIfAllreadyConnectSocialNetwork(){
        let defaults = NSUserDefaults.standardUserDefaults()
        if(defaults.stringForKey("guid") != nil){
            let guid = defaults.stringForKey("guid")!
            
            let headers = ["Authorization": guid]
            
            Alamofire.request(.GET, "http://wevoapi.azurewebsites.net:80/api/login/"+guid , parameters: nil, headers: headers).responseJSON { response in
                print(response)
                let resultDic : NSDictionary =  (response.result.value as? NSDictionary)!
                defaults.setObject(resultDic.valueForKey("data")!.valueForKey("isfacebook"), forKey: "isFacebookUser")
                defaults.setObject(resultDic.valueForKey("data")!.valueForKey("isGoogle"), forKey: "isGoogleUser")
                defaults.setObject(resultDic.valueForKey("data")!.valueForKey("isInstagram"), forKey: "isInstagramUser")
                defaults.setObject(resultDic.valueForKey("data")!.valueForKey("isYoutube"), forKey: "isYoutubeUser")
                defaults.setObject(resultDic.valueForKey("data")!.valueForKey("isContacts"), forKey: "isContacts")
                
                //start load contacts if need only after checking
                let defaults = NSUserDefaults.standardUserDefaults()
                let isContacts = defaults.stringForKey("isContacts")
                ///////
                
                
                
                
                
                self.showAlertViewSync("Phone contacts", message: "WEVO whant to sync you phone book contacts", contact:isContacts!)
                
                
                
                ////

                
            }
        }

    }
    func startActivity() {
        
        activity.hidden = false
        activity.startAnimating()
    }
    
    func stopActivity() {
        
        activity.hidden = true
        activity.stopAnimating()
    }
    
    func showAlertView(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    func showAlertViewSync(title: String, message: String, contact: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default) { (alert: UIAlertAction!) -> Void in
          //  if contact == "false"{
                self.startActivity()
                AppDelegate.sharedDelegate().checkAccessStatus({ (accessGranted) -> Void in
                    if accessGranted {
                        
                    }
                })
                self.loadContactsList()
                self.preperContactDetailsToDB()
           // }
        }
        alert.addAction(okAction)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //Action methods
    
    @IBAction func ConnectWithInstagram(sender: AnyObject) {
        let defaults = NSUserDefaults.standardUserDefaults()
        let isInstagram = defaults.stringForKey("isInstagramUser")
        if isInstagram == "true"{
            self.showAlertView("Error", message: "allready connect")
            
            return
        }

        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("vcUserInstagramDetails") as? UserInstagramDetailsViewController
        self.navigationController?.pushViewController(vc!, animated: true)
        
    }
    
    @IBAction func ConnectWithGoogle(sender: AnyObject) {
        let defaults = NSUserDefaults.standardUserDefaults()

        let isGoogle = defaults.stringForKey("isGoogleUser")
        if isGoogle == "true"{
            self.showAlertView("Error", message: "allready connect")
            
            return
        }
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("vcUserGoogleDetails") as? UserGoogleDetailsViewController
        self.navigationController?.pushViewController(vc!, animated: true)
        
    }
    @IBAction func ConnectWithYoutube(sender: AnyObject) {
        let defaults = NSUserDefaults.standardUserDefaults()
        let isGoogle = defaults.stringForKey("isGoogleUser")
        if isGoogle == "false"{
            self.showAlertView("Error", message: "Must connect google frst")

            return
        }
        let isYoutube = defaults.stringForKey("isYoutubeUser")

        if isYoutube == "true"{
            self.showAlertView("Error", message: "allready connect")
            
            return
        }
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("vcYoutubeConnect") as? UserYoutubeViewController
        self.navigationController?.pushViewController(vc!, animated: true)
        
    }
    
    @IBAction func ConnectWithFacebook(sender: AnyObject) {
     let defaults = NSUserDefaults.standardUserDefaults()
        
        let isFacebook = defaults.stringForKey("isFacebookUser")
        if isFacebook == "true"{
            self.showAlertView("Error", message: "allready connect")
            
            return
        }
        self.startActivity()

        facebookConnectBtn.hidden = true
        

         let guid = defaults.stringForKey("guid")

//        if(FBSDKAccessToken.currentAccessToken() != nil && userId != nil) {
//            print(FBSDKAccessToken.currentAccessToken())
//            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("vcGroupsViewController") as? GroupsController
//            self.navigationController?.pushViewController(vc!, animated: true)
//        } else {
            print("no access token")
            let permissions = ["public_profile", "email", "user_friends","user_likes", "user_photos", "user_location","user_tagged_places"]
            PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions as [AnyObject]) {
                (user: PFUser?, error: NSError?) -> Void in
                //let defaults = NSUserDefaults.standardUserDefaults()
                
                defaults.setObject("true", forKey: "isFacebookUser")
                if let user = user {
                    if user.isNew {
                        print("User signed up and logged in through Facebook!")
                        let accesstoken = FBSDKAccessToken.currentAccessToken().tokenString
                        defaults.setObject(accesstoken, forKey: "facebookToken")

                        let parametersToSend = [
                            "stringValue": accesstoken
                        ]
                        let headers = ["Authorization": guid!]

                        Alamofire.request(.POST, "http://wevoapi.azurewebsites.net:80/api/login/facebook/", parameters: parametersToSend, headers: headers).responseJSON { response in
                            print(response)
                            if(response.result.value === NSNull() || response.result.value === nil){
                                self.showAlertView("Error", message: "NULL object")
                                
                            }else{
                                let resultDic : NSDictionary =  (response.result.value as? NSDictionary)!
                                print(resultDic.valueForKey("data")!.valueForKey("FullName"))
                                print(resultDic.valueForKey("data")!.valueForKey("Picture"))

                                //UserId must be equal to giud
                                //defaults.setObject(resultDic.valueForKey("data")!.valueForKey("userId"), forKey: "UserId")
                                let vc = self.storyboard?.instantiateViewControllerWithIdentifier("vcConnectionCollectionViewController") as? ConnectionCollectionViewController
                                self.navigationController?.pushViewController(vc!, animated: true)
                            }

                        }
                        self.stopActivity()
                        
                    } else {
                        print("User logged in through Facebook!")
                        //need to find by facebook id and update the nodes
                        let accesstoken = FBSDKAccessToken.currentAccessToken().tokenString
                        defaults.setObject(accesstoken, forKey: "facebookToken")

                        let parametersToSend = [
                            "stringValue": accesstoken
                        ]
                        let headers = ["Authorization": guid!]

                        //change to post becuase accesstoken to long
                        Alamofire.request(.POST, "http://wevoapi.azurewebsites.net:80/api/login/facebook/", parameters: parametersToSend, headers: headers).responseJSON { response in
                            print(response)
                            if(response.result.value === NSNull() || response.result.value === nil){
                                self.showAlertView("Error", message: "NULL object")
                                
                            }
                                
                            else{
                                let resultDic : NSDictionary =  (response.result.value as? NSDictionary)!
                                print(resultDic.valueForKey("data")!.valueForKey("FullName"))
                                print(resultDic.valueForKey("data")!.valueForKey("Picture"))
                                //defaults.setObject(resultDic.valueForKey("data")!.valueForKey("userId"), forKey: "UserId")
                                
                                let vc = self.storyboard?.instantiateViewControllerWithIdentifier("vcConnectionCollectionViewController") as? ConnectionCollectionViewController
                                self.navigationController?.pushViewController(vc!, animated: true)
                                
                            }
                            
                        }
                    }
                } else {
                    print("Uh oh. The user cancelled the Facebook login.")
                }
            }
      //  }
    }
    
    @IBAction func goToOtherSocial(sender: AnyObject) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("vcChooseOtherSocialViewController") as? ChooseOtherSocialViewController
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    // Skip to home page if registered
    @IBAction func actionSkip(sender: AnyObject) {
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let userId = defaults.stringForKey("guid")
        let status = defaults.stringForKey("status")
        
        
        if userId != nil || status == "approve"{
            
            let vc = self.storyboard?.instantiateInitialViewController()
            
            presentViewController(vc!, animated: true, completion: nil)
        }

    }
    
    //    @IBAction func facebookConnectAction(sender: AnyObject)
    //    {
    //        let permissions = ["public_profile", "email", "user_friends","user_likes"] // << declaring permissions as empty array
    //        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions as [AnyObject]) {
    //            (user: PFUser?, error: NSError?) -> Void in
    //            if let user = user {
    //                if user.isNew {
    //                    print("User signed up and logged in through Facebook!")
    //                } else {
    //                    print("User logged in through Facebook!")
    //                    //
    //
    //                    //
    //                }
    //            } else {
    //                print("Uh oh. The user cancelled the Facebook login.")
    //            }
    //        }
    //        if(FBSDKAccessToken.currentAccessToken() != nil) {
    //            print(FBSDKAccessToken.currentAccessToken())
    //        } else {
    //            print("no access token")
    //        }
    
    
    
    
    /*
    if (indexPath.row == tableData.count-1 && nextPageURL != nil) {
    [self showActivityViewerWithDelay:self.view andText:@"המתן..."];
    [FBRequestConnection startWithGraphPath:[nextPageURL substringFromIndex:27] completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
    if (!error) {
    
    FacebookFriendsData *facebookFriendsData = [self parseFacebookFriendsResult:result];
    facebookFriendsData = [facebookFriendsData arrangeFacebookFriendsByName];
    
    [tableData addObjectsFromArray:facebookFriendsData.facebookFriendsDataArray];
    [self.tblFriends reloadData];
    
    } else {
    NSLog(@"An error occurred getting friends: %@", [error localizedDescription]);
    }
    [self hideActivityViewer];
    }];
    }
    //
    nextPageURL = [dictionary setValidObjectForKeyPath:@"paging.next"];
    */
    
    
    
    
    //    }

}
extension String{
    func exclude(find:String) -> String {
        return stringByReplacingOccurrencesOfString(find, withString: "", options: .LiteralSearch, range: nil)
    }
    func replaceAll(find:String, with:String) -> String {
        return stringByReplacingOccurrencesOfString(find, withString: with, options: .LiteralSearch, range: nil)
    }
}




