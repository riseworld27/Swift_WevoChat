//
//  UserInstagramDetailsViewController.swift
//  commontech
//
//  Created by matata on 17/10/2015.
//  Copyright © 2015 matata. All rights reserved.
//

import UIKit
import OAuthSwift
import Alamofire
class UserInstagramDetailsViewController: UIViewController {
    var checked = [Bool]()

    @IBOutlet weak var activity: UIActivityIndicatorView!

    // MARK: screen Properties
    @IBOutlet weak var tblInstagramDetails: UITableView!
    @IBAction func InstaramReloadData(sender: AnyObject) {
        self.getInstagramData()
    }
    @IBAction func saveMarkItems(sender: AnyObject) {
        self.printSelectedItems()
    }
    @IBOutlet weak var instagramReloadTableBtn: UIButton!
    // MARK: global Properties
    var selectedItems: [String: Bool] = [:]

    var detailsInstagram: [InstagramFriends] = []
    var saveSelected: [InstagramFriends] = []

    var instagramFeed: [InstagramFeed] = []
    //need to save on device to prevet extra autantication
    var credentialInstagram: String = ""
 
    
    var services = ["Instagram" ]
    // MARK : override functions
    override func viewDidLoad() {
        super.viewDidLoad()
        dispatch_async(dispatch_get_main_queue(), {
            self.doOAuthInstagram()

            return
        })
        dispatch_async(dispatch_get_main_queue(), {
            self.tblInstagramDetails.reloadData()
            return
        })

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    // MARK : OAuthSwift
    func doOAuthInstagram(){
        let oauthswift = OAuth2Swift(
            consumerKey:    Instagram["consumerKey"]!,
            consumerSecret: Instagram["consumerSecret"]!,
            authorizeUrl:   "https://api.instagram.com/oauth/authorize",
            responseType:   "token"
        )
        let defaults = NSUserDefaults.standardUserDefaults()
        let isToken  = defaults.stringForKey("instagramToken")
        if(isToken != nil){
            self.credentialInstagram = isToken!
            self.getInstagramData()

        }
        let state: String = generateStateWithLength(20) as String
        oauthswift.authorize_url_handler = WebViewController()
        oauthswift.authorizeWithCallbackURL( NSURL(string: "igf9469d014dfb455d92910ae33b9111f5://authorize")!, scope: "likes+comments", state:state, success: {
            credential, response, parameters in
          //  self.showAlertView("Instagram", message: "oauth_token:\(credential.oauth_token)")
            self.credentialInstagram = credential.oauth_token
              defaults.setObject(credential.oauth_token, forKey: "instagramToken")

            self.getInstagramData()
            }, failure: {(error:NSError!) -> Void in
                print(error.localizedDescription)
        })
    }
    func getInstagramData(){
//        let oauthswift = OAuth2Swift(
//            consumerKey:    Instagram["consumerKey"]!,
//            consumerSecret: Instagram["consumerSecret"]!,
//            authorizeUrl:   "https://api.instagram.com/oauth/authorize",
//            responseType:   "token"
//        )
        //let url :String = "https://api.instagram.com/v1/users/self/feed?access_token=\(credential.oauth_token)"
        //let url :String = "https://api.instagram.com/v1/users/self/feed?access_token=\(self.credentialInstagram)"
       // let url :String = "https://api.instagram.com/v1/users/self/?access_token=\(self.credentialInstagram)"
        let accesstoken = self.credentialInstagram
        let parametersToSend = [
            "stringValue": accesstoken
        ]
        let postEndpoint = "http://wevoapi.azurewebsites.net:80/api/login/instagram"
        let defaults = NSUserDefaults.standardUserDefaults()
        
        let guid = defaults.stringForKey("guid")
        let headers = ["Authorization": guid!]
	
        Alamofire.request(.POST, postEndpoint, parameters:  parametersToSend, headers: headers).responseJSON { response in
            print(response)
            if(response.result.value === NSNull() || response.result.value === nil){
                self.showAlertView("Error", message: "NULL object")
                
            }else{
                let resultDic : NSDictionary =  (response.result.value as? NSDictionary)!
                print(resultDic.valueForKey("data")!.valueForKey("FullName"))
                print(resultDic.valueForKey("data")!.valueForKey("Picture"))
                let defaults = NSUserDefaults.standardUserDefaults()
                
                defaults.setObject("true", forKey: "isInstagramUser")
            }
            
            
        }
        // 38340011
//        let defaults = NSUserDefaults.standardUserDefaults()
//        let Userkey = defaults.stringForKey("Userkey")
        
        //TODO: need to past to server side
//        let parameters :Dictionary = Dictionary<String, AnyObject>()
//        oauthswift.client.get(url, parameters: parameters,
//            success: {
//                data, response in
//                let jsonDict: AnyObject! = try? NSJSONSerialization.JSONObjectWithData(data, options: [])
//                let resultDic : NSDictionary =  (jsonDict.valueForKey("data") as? NSDictionary)!
//                    print(resultDic)
//                let resultDic : NSArray =  (jsonDict.valueForKey("data") as? NSArray)!
//                for item in resultDic {
//                    // print(item)
//                    let userData : NSDictionary =  (item.valueForKey("user") as? NSDictionary)!
//                    // let pictureUrl : NSDictionary =  (pictureData.valueForKey("data") as? NSDictionary)!
//                    let instagramFriend =  InstagramFriends( Id: (userData.valueForKey("id") as? String)!, Name: (userData.valueForKey("full_name") as? String)!, Picture: NSURL(string: (userData.valueForKey("profile_picture") as? String)!)!)!
//                    self.detailsInstagram.append(instagramFriend)
//                    if(item.valueForKey("caption") !== NSNull()){
//                        let userData2 : NSDictionary =  (item.valueForKey("caption") as? NSDictionary)!
//                        let from : NSDictionary =  (userData2.valueForKey("from") as? NSDictionary)!
//                        
//                        let instagramFeed =  InstagramFeed(
//                            created_time: (userData2.valueForKey("created_time") as? String)!,
//                            username: (from.valueForKey("username") as? String)!,
//                            id: (from.valueForKey("id") as? String)!,
//                            picture: NSURL(string: (from.valueForKey("profile_picture") as? String)!)!,
//                            full_name: (from.valueForKey("full_name") as? String)!,
//                            captionId: (userData2.valueForKey("id") as? String)!,
//                            text: (userData2.valueForKey("text") as? String)!)!
//                        
//                        self.instagramFeed.append(instagramFeed)
//                    }
//
//                }
//                self.do_table_refresh();
//        
//                for(var i = 0 ; i < self.instagramFeed.count; i++){
//                    let parametersToSend = [
//                        "userkey": (Userkey as? AnyObject)!,
//                        "userUDID": AppDelegate.sharedDelegate().checkIdentifierForVendor(),
//                        "created_time": self.instagramFeed[i].created_time,
//                        "username": self.instagramFeed[i].username,
//                        "id": self.instagramFeed[i].id,
//                        "picture": self.instagramFeed[i].picture,
//                        "full_name": self.instagramFeed[i].full_name,
//                        "captionId": self.instagramFeed[i].captionId,
//                        "text": self.instagramFeed[i].text
//                        
//                    ]
//                    let postEndpoint = "http://wevoapi.azurewebsites.net:80/api/UserInstagram/Feed"
//                    
//                    Alamofire.request(.POST, postEndpoint, parameters:  parametersToSend).responseJSON { response in
//                        print(response)
//                        
//                    }
//                }
//                
//                //  print(jsonDict)
//            }, failure: {(error:NSError!) -> Void in
//                print(error)
//        })
    }
    func do_table_refresh()
    {
        dispatch_async(dispatch_get_main_queue(), {
            self.tblInstagramDetails.reloadData()
            return
        })
    }
    
    func showAlertView(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    

}
//MARK: - UITableViewDataSource

extension UserInstagramDetailsViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int  {
        return detailsInstagram.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath:NSIndexPath) -> UITableViewCell {
        let CellIdentifier = "InstagramCell"

        //let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: CellIdentifier) as! InstagramCells
        let instagramCell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier, forIndexPath: indexPath) as! InstagramCells

        let instagramFriend = self.detailsInstagram[indexPath.row]
        if let label = instagramCell.lblName{
            label.text = instagramFriend.Name
        }
        if let url = instagramCell.lblImage{
            if let data = NSData(contentsOfURL: instagramFriend.Picture){
                url.contentMode = UIViewContentMode.ScaleAspectFit
                url.image = UIImage(data: data)
            }
        }
  
        return instagramCell
    }
}

//MARK: - UITableViewDelegate
extension UserInstagramDetailsViewController: UITableViewDelegate {

//    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
//        
//        return 3
//    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
   
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {

            if cell.accessoryType == .Checkmark
            {
                cell.accessoryType = .None
               // checked[indexPath.row] = false
            }
            else
            {
                cell.accessoryType = .Checkmark
            //    checked[indexPath.row] = true
            }
        }
    }
    func printSelectedItems() {
        for i in 0...self.tblInstagramDetails.numberOfSections-1
        {
            for j in 0...self.tblInstagramDetails.numberOfRowsInSection(i)-1
            {
                if let cell = self.tblInstagramDetails.cellForRowAtIndexPath(NSIndexPath(forRow: j, inSection: i)) {
                    
 
                    if cell.accessoryType == .Checkmark
                    {
                        self.saveSelected.append(self.detailsInstagram[j])
                        print(self.saveSelected)
                    }

                }
                
            }
        }
    }
    
    //TODO : change to save to group
    func saveListToDB()
    {
        activity.hidden = false
        activity.startAnimating()
        for(var i = 0 ; i < self.saveSelected.count; i++){
            let parametersToSend = [
                "username": self.saveSelected[i].Name,
                "id": self.saveSelected[i].Id,
                "picture": self.saveSelected[i].Picture,
                
            ]
            let postEndpoint = "http://wevoapi.azurewebsites.net:80/api/UserInstagram/Feed"
            
            Alamofire.request(.POST, postEndpoint, parameters:  parametersToSend).responseJSON { response in
                print(response)
                
            }
        }
        activity.hidden = true
        activity.stopAnimating()
    }

    
}



