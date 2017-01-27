//
//  UserGoogleDetailsViewController.swift
//  commontech
//
//  Created by matata on 29/10/2015.
//  Copyright © 2015 matata. All rights reserved.
//

import UIKit
import OAuthSwift
import Alamofire

class UserGoogleDetailsViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        doOAuthGoogle()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func parametersFromQueryString(queryString: String?) -> [String: String] {
        var parameters = [String: String]()
        if (queryString != nil) {
            let parameterScanner: NSScanner = NSScanner(string: queryString!)
            var name:NSString? = nil
            var value:NSString? = nil
            while (parameterScanner.atEnd != true) {
                name = nil;
                parameterScanner.scanUpToString("=", intoString: &name)
                parameterScanner.scanString("=", intoString:nil)
                value = nil
                parameterScanner.scanUpToString("&", intoString:&value)
                parameterScanner.scanString("&", intoString:nil)
                if (name != nil && value != nil) {
                    parameters[name!.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())!]
                        = value!.stringByAddingPercentEncodingWithAllowedCharacters(.URLHostAllowedCharacterSet())
                }
            }
        }
        return parameters
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
            print("oauth_token:\(credential.oauth_token)")
            print("\n client oauth_token - " + credential.oauth_token)
            print("\n client oauth_token_secret - " + credential.oauth_token_secret)

            defaults.setObject(credential.oauth_token, forKey: "googleToken")
            defaults.setObject(parameters["refresh_token"] , forKey: "googleRefreshToken")
            //var parameters =  Dictionary<String, AnyObject>()
           // parameters["oauth_nonce"] = credential.oauth_token

            //TODO: send oauth
            let parametersToSend = [
                "stringValue": credential.oauth_token
            ]
            let guid = defaults.stringForKey("guid")

            let headers = ["Authorization": guid!]

            Alamofire.request(.POST, "http://wevoapi.azurewebsites.net:80/api/login/google/", parameters: parametersToSend,headers: headers).responseJSON { response in
                print(response)
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
}
