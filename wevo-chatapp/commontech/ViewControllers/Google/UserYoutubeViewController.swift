//
//  UserYoutubeViewController.swift
//  commontech
//
//  Created by matata on 22/12/2015.
//  Copyright © 2015 matata. All rights reserved.
//

import UIKit
import OAuthSwift
import Alamofire
class UserYoutubeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        doOAuthYoutube()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
            print("\n client oauth_token - " + credential.oauth_token)
            print("\n client oauth_token_secret - " + credential.oauth_token_secret)
          //  var parameters =  Dictionary<String, AnyObject>()
          //  parameters["oauth_nonce"] = credential.oauth_token
            let parametersToSend = [
                "stringValue": credential.oauth_token
            ]
            let guid = defaults.stringForKey("guid")
            
            let headers = ["Authorization": guid!]
            Alamofire.request(.POST, "http://wevoapi.azurewebsites.net:80/api/login/youtube/", parameters: parametersToSend, headers: headers).responseJSON { response in
                print(response)
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
}
