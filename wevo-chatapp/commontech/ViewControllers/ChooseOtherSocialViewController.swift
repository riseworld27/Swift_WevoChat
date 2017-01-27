//
//  ChooseOtherSocialViewController.swift
//  commontech
//
//  Created by matata on 12/01/2016.
//  Copyright © 2016 matata. All rights reserved.
//

import UIKit
import OAuthSwift
import Alamofire

class ChooseOtherSocialViewController: UIViewController {
    @IBOutlet weak var navItem: WevoNavigationBar!
    @IBOutlet weak var activity: UIActivityIndicatorView!

    @IBOutlet weak var wevoLogoImg: UIImageView!

    @IBOutlet weak var googleBtn: UIButton!
    @IBOutlet weak var instagramBtn: UIButton!
    @IBOutlet weak var twitterBtn: UIButton!
    @IBOutlet weak var linkedinBtn: UIButton!
    var credentialInstagram: String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
        activity.hidden = true
        // self.initNavBar()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func initNavBar() {
        
        self.navItem!.showBackLeftBtn()
        (self.navItem.leftBarButtonItem?.customView as! UIButton).addTarget(self, action: "backAction:", forControlEvents: UIControlEvents.TouchUpInside)
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
    //MARK: - instagram connect
    @IBAction func ConnectWithInstagram(sender: AnyObject) {
        let defaults = NSUserDefaults.standardUserDefaults()
        let isInstagram = defaults.stringForKey("isInstagramUser")
//        if isInstagram == "true"{
//            self.showAlertView("Error", message: "allready connect")
//            
//            return
//        }
            //{SN} do not past to diffrent controller
//        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("vcUserInstagramDetails") as? UserInstagramDetailsViewController
//        self.navigationController?.pushViewController(vc!, animated: true)
        self.startActivity()
        self.doOAuthInstagram()

    }
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
            self.stopActivity()
            if(response.result.value === NSNull() || response.result.value === nil){
                self.showAlertView("Error", message: "NULL object")
                
            }else{
                let resultDic : NSDictionary =  (response.result.value as? NSDictionary)!
                print(resultDic.valueForKey("data")!.valueForKey("FullName"))
                print(resultDic.valueForKey("data")!.valueForKey("Picture"))
                let defaults = NSUserDefaults.standardUserDefaults()
                
                defaults.setObject("true", forKey: "isInstagramUser")
                let vc = self.storyboard?.instantiateViewControllerWithIdentifier("vcConnectionCollectionViewController") as? ConnectionCollectionViewController
                self.navigationController?.pushViewController(vc!, animated: true)
            }
            
            
        }

    }
    //MARK: - connect google
    @IBAction func ConnectWithGoogle(sender: AnyObject) {
        let defaults = NSUserDefaults.standardUserDefaults()
        
        let isGoogle = defaults.stringForKey("isGoogleUser")
//        if isGoogle == "true"{
//            self.showAlertView("Error", message: "allready connect")
//            
//            return
//        }
//        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("vcUserGoogleDetails") as? UserGoogleDetailsViewController
//        self.navigationController?.pushViewController(vc!, animated: true)
        self.startActivity()
        self.doOAuthGoogle()

        
    }
    func doOAuthGoogle(){
        let oauthswift = OAuth2Swift(
            consumerKey:    GoogleYoutube["consumerKey"]!,
            consumerSecret: GoogleYoutube["consumerSecret"]!,
            authorizeUrl:   "https://accounts.google.com/o/oauth2/auth",
            accessTokenUrl: "https://accounts.google.com/o/oauth2/token",
            responseType:   "code"
        )
        //https://www.googleapis.com/auth/youtube,
        // For googgle the redirect_uri should match your this syntax: your.bundle.id:/oauth2Callback
        // in plist define a url schem with: your.bundle.id:
        let myScopeGooglePlus = "https://www.googleapis.com/auth/plus.login"
        //userinfo.profile
        let defaults = NSUserDefaults.standardUserDefaults()
        
        
        
        oauthswift.authorizeWithCallbackURL( NSURL(string: "W2GCW24QXG.com.scent.Scent:/oauth-swift")!, scope: myScopeGooglePlus, state: "", success: {
            credential, response, parameters in
//            print("oauth_token:\(credential.oauth_token)")
            defaults.setObject(credential.oauth_token, forKey: "googleToken")
            defaults.setObject(parameters["refresh_token"] , forKey: "googleRefreshToken")
 
            let parametersToSend = [
                "stringValue": credential.oauth_token
            ]
            let guid = defaults.stringForKey("guid")
            
            let headers = ["Authorization": guid!]
            
            Alamofire.request(.POST, "http://wevoapi.azurewebsites.net:80/api/login/google/", parameters: parametersToSend,headers: headers).responseJSON { response in
                print(response)
                self.stopActivity()
                //let resultDic : NSDictionary =  (response.result.value as? NSDictionary)!
                let defaults = NSUserDefaults.standardUserDefaults()
                
                defaults.setObject("true", forKey: "isGoogleUser")
                let vc = self.storyboard?.instantiateViewControllerWithIdentifier("vcConnectionCollectionViewController") as? ConnectionCollectionViewController
                self.navigationController?.pushViewController(vc!, animated: true)
            }
            
            }, failure: {(error:NSError!) -> Void in
                print("ERROR: \(error.localizedDescription)")
        })
    }
    //MARK: connect with youtube
    @IBAction func ConnectWithYoutube(sender: AnyObject) {
        let defaults = NSUserDefaults.standardUserDefaults()
        let isGoogle = defaults.stringForKey("isGoogleUser")
//        if isGoogle == "false"{
//            self.showAlertView("Error", message: "Must connect google frst")
//            
//            return
//        }
        let isYoutube = defaults.stringForKey("isYoutubeUser")
        
//        if isYoutube == "true"{
//            self.showAlertView("Error", message: "allready connect")
//            
//            return
//        }
//        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("vcYoutubeConnect") as? UserYoutubeViewController
//        self.navigationController?.pushViewController(vc!, animated: true)
        self.startActivity()
        self.doOAuthYoutube()

    }
    func doOAuthYoutube(){
        let oauthswift = OAuth2Swift(
            consumerKey:    GoogleYoutube["consumerKey"]!,
            consumerSecret: GoogleYoutube["consumerSecret"]!,
            authorizeUrl:   "https://accounts.google.com/o/oauth2/auth",
            accessTokenUrl: "https://accounts.google.com/o/oauth2/token",
            responseType:   "code"
        )
        let defaults = NSUserDefaults.standardUserDefaults()
        
        let myScopeYoutube = "https://www.googleapis.com/auth/youtube"
        
        
        oauthswift.authorizeWithCallbackURL( NSURL(string: "W2GCW24QXG.com.scent.Scent:/oauth-swift")!, scope: myScopeYoutube, state: "", success: {
            credential, response, parameters in
            
            defaults.setObject(credential.oauth_token, forKey: "youtubeToken")
            defaults.setObject(parameters["refresh_token"] , forKey: "youtubeRefreshToken")
            
            print("oauth_token:\(credential.oauth_token)")

            let parametersToSend = [
                "stringValue": credential.oauth_token
            ]
            let guid = defaults.stringForKey("guid")
            
            let headers = ["Authorization": guid!]
            Alamofire.request(.POST, "http://wevoapi.azurewebsites.net:80/api/login/youtube/", parameters: parametersToSend, headers: headers).responseJSON { response in
                print(response)
                self.stopActivity()
                //let resultDic : NSDictionary =  (response.result.value as? NSDictionary)!
                let defaults = NSUserDefaults.standardUserDefaults()
                
                defaults.setObject("true", forKey: "isYoutubeUser")
                let vc = self.storyboard?.instantiateViewControllerWithIdentifier("vcConnectionCollectionViewController") as? ConnectionCollectionViewController
                self.navigationController?.pushViewController(vc!, animated: true)
            }
            }, failure: {(error:NSError!) -> Void in
                print("ERROR: \(error.localizedDescription)")
        })
    }
    @IBAction func ConnectWithLinkedin(sender: AnyObject) {
        self.showAlertView("Error", message: "not implemented yet")

    }

    @IBAction func backAction(sender: AnyObject) {
        self.navigationController!.popViewControllerAnimated(true)
    }
}
