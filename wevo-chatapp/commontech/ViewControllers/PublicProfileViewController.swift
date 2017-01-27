//
//  PublicProfileViewController.swift
//  commontech
//
//  Created by Daniel Fassler on 1/26/16.
//  Copyright © 2016 matata. All rights reserved.
//

import UIKit
import Alamofire

class PublicProfileViewController: UIViewController {

    @IBOutlet weak var lblItsMe: UILabel!
    
    @IBOutlet weak var lblMyName: UILabel!
    
    @IBOutlet weak var imgMyProfile: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = NSUserDefaults.standardUserDefaults()

        let postEndpoint = "http://wevoapi.azurewebsites.net:80/api/users/"+defaults.stringForKey("guid")!
        
        let headers = ["Authorization": defaults.stringForKey("guid")!]
        Alamofire.request(.GET, postEndpoint, parameters:  nil, headers: headers).responseJSON { response in
            print(response)
            let resultDic : NSDictionary =  (response.result.value as? NSDictionary)!
            if resultDic.valueForKey("data") === NSNull(){
                let alert = UIAlertController(title: "Error", message: "Data is null", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
                
                self.presentViewController(alert, animated: true, completion: nil)
            }else{
                
                // let firstName = (resultDic.valueForKey("data")!.valueForKey("FirstName") as? String)!
                // self.lblMyName.text = firstName

                let name = (resultDic.valueForKey("data")!.valueForKey("Name") as? String)!
                self.lblMyName.text = name
                
                if let url = NSURL(string: (resultDic.valueForKey("data")!.valueForKey("Picture") as? String)!) {
                    if let data = NSData(contentsOfURL: url){
                        self.imgMyProfile.contentMode = UIViewContentMode.ScaleAspectFill
                        self.imgMyProfile.image = UIImage(data: data)
                    }
                }
            }
        }    }

    override func viewDidLayoutSubviews() {
        // make the profile image circular
        imgMyProfile.layer.cornerRadius = imgMyProfile.frame.size.width / 2.0
        imgMyProfile.clipsToBounds = true
        
        // stylize "It's me" label
        lblItsMe.layer.cornerRadius = 12
        lblItsMe.layer.borderColor = UIColor(colorLiteralRed: 197/255, green: 1.0, blue: 116/255, alpha: 1.0).CGColor
        lblItsMe.layer.borderWidth = 1
        lblItsMe.clipsToBounds = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
