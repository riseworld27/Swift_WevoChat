//
//  UserFacebookDetailsViewController.swift
//  commontech
//
//  Created by matata on 15/10/2015.
//  Copyright © 2015 matata. All rights reserved.
//

import UIKit
import Alamofire
class UserFacebookDetailsViewController: UIViewController {

    var isMe: Bool = true
    var userId: String!
    @IBAction func goHome(sender: AnyObject) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("vcConnectionCollectionViewController") as? ConnectionCollectionViewController
        // self.navigationController?.pushViewController(vc!, animated: true)
        // Home button should push or pop to previous view controller?
        self.navigationController?.popViewControllerAnimated(true)
    }
    @IBAction func gotoProfile(sender: AnyObject) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("vcUserFacebookDetails") as? UserFacebookDetailsViewController
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
    
    @IBOutlet weak var btnTaggableFriends: UIButton!
    var taggableFriends = [Friends]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated:true);
        let defaults = NSUserDefaults.standardUserDefaults()
//        let UserId = defaults.stringForKey("UserId")
        var postEndpoint = ""
        if isMe{
             postEndpoint = "http://wevoapi.azurewebsites.net:80/api/users/"+defaults.stringForKey("guid")!

        }else{
            postEndpoint = "http://wevoapi.azurewebsites.net:80/api/users/"+self.userId

        }
        let headers = ["Authorization": defaults.stringForKey("guid")!]
        Alamofire.request(.GET, postEndpoint, parameters:  nil, headers: headers).responseJSON { response in
            print(response)
            let resultDic : NSDictionary =  (response.result.value as? NSDictionary)!
            if resultDic.valueForKey("data") === NSNull(){
                let alert = UIAlertController(title: "Error", message: "Data is null", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
                
                self.presentViewController(alert, animated: true, completion: nil)
            }else{
           
                self.firstNameTxt.text = (resultDic.valueForKey("data")!.valueForKey("FirstName") as? String)!
                self.lastNameTxt.text = (resultDic.valueForKey("data")!.valueForKey("LastName") as? String)!
                self.nameTxt.text = (resultDic.valueForKey("data")!.valueForKey("Name") as? String)!
                if let isEmail = resultDic.valueForKey("data")!.valueForKey("Email")as? String {
                    self.emailTxt.text = isEmail
                }
                else{
                    self.emailTxt.text = ""
                    
                }
                
                self.idTxt.text = (resultDic.valueForKey("data")!.valueForKey("facebookId") as? String)!
                self.pictureURLTxt.text = (resultDic.valueForKey("data")!.valueForKey("Picture") as? String)!
                if let url = NSURL(string: (resultDic.valueForKey("data")!.valueForKey("Picture") as? String)!) {
                    if let data = NSData(contentsOfURL: url){
                        self.pictureURLImage.contentMode = UIViewContentMode.ScaleAspectFit
                        self.pictureURLImage.image = UIImage(data: data)
                    }
                }
            }
        }
    }
    

//                let graphRequest1 : FBSDKGraphRequest = FBSDKGraphRequest(graphPath:  "me/music", parameters: nil)
//                graphRequest1.startWithCompletionHandler({ (connection, result, error) -> Void in
//        
//                    if ((error) != nil)
//                    {
//                        // Process error
//                        //print("Error: \(error)")
//                    }
//                    else
//                    {
//        
//                        //print("\(result)")
//                        let resultArray : NSArray =  (result.valueForKey("data") as? NSArray)!
//
//                        let defaults = NSUserDefaults.standardUserDefaults()
//                        let Userkey = defaults.stringForKey("Userkey")
//                        for(var i = 0; i < resultArray.count;i++)
//                        {
//                            //send to server
//                            let parametersToSend = [
//                                "userkey": (Userkey as? AnyObject)!,
//                                "userUDID": AppDelegate.sharedDelegate().checkIdentifierForVendor(),
//                                "created_time": (resultArray[i].valueForKey("created_time") as? String)!,
//                                "musicId": (resultArray[i].valueForKey("id") as? String)!,
//                                "name": (resultArray[i].valueForKey("name") as? String)!
//                                
//                            ]
//                            let postEndpoint = "http://wevoapi.azurewebsites.net:80/api/UserFacebook/Music"
//                            Alamofire.request(.POST, postEndpoint, parameters:  parametersToSend).responseJSON { response in
//                                //print(response)
//                                
//                            }
//                        }
//                    }
//                })
//        let defaults = NSUserDefaults.standardUserDefaults()
//        let Userkey = defaults.stringForKey("Userkey")
//        
//        let fbRequest = FBSDKGraphRequest(graphPath:"/me/taggable_friends", parameters:nil);
//        fbRequest.startWithCompletionHandler { (connection : FBSDKGraphRequestConnection!, result : AnyObject!, error : NSError!) -> Void in
//            
//            if error == nil {
//                let resultDic : NSArray =  (result.valueForKey("data") as? NSArray)!
//                for item in resultDic {
//                    print(item)
//                    let pictureData : NSDictionary =  (item.valueForKey("picture") as? NSDictionary)!
//                    let pictureUrl : NSDictionary =  (pictureData.valueForKey("data") as? NSDictionary)!
//                    
//                    
//                    let tagfriend =  TaggableFriends(name: (item.valueForKey("name") as? String)!, id: (item.valueForKey("id") as? String)!, picture: NSURL(string: (pictureUrl.valueForKey("url") as? String)!)!)!
//                    
//                    self.taggableFriends.append(tagfriend)
//                    let parametersToSend = [
//                        "userkey": (Userkey as? AnyObject)!,
//                        "userUDID": AppDelegate.sharedDelegate().checkIdentifierForVendor(),
//                        "facebookId": (item.valueForKey("id") as? String)!,
//                        "Name": (item.valueForKey("name") as? String)!,
//                        "Picture": (pictureUrl.valueForKey("url") as? String)!,
//                        
//                    ]
//                    //endPoint:http://wevoapp.azurewebsites.net/api/userfacebook
//                    let postEndpoint = "http://wevoapi.azurewebsites.net:80/api/UserFacebook/taggableFriends"
//                    
//                    Alamofire.request(.POST, postEndpoint, parameters:  parametersToSend).responseJSON { response in
//                        print(response)
//                        
//                    }
//                    
//                }
//                
//                
//                
//            } else {
//                
//                print("Error Getting Friends \(error)");
//                
//            }
//        }
//
//        
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBOutlet weak var firstNameTxt: UILabel!
    @IBOutlet weak var lastNameTxt: UILabel!
    @IBOutlet weak var nameTxt: UILabel!
    @IBOutlet weak var emailTxt: UILabel!
    @IBOutlet weak var idTxt: UILabel!
    @IBOutlet weak var pictureURLTxt: UILabel!
    @IBOutlet weak var pictureURLImage: UIImageView!



}
