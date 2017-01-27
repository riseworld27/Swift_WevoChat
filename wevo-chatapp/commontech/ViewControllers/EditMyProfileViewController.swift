//
//  EditMyProfileViewController.swift
//  commontech
//
//  Created by Daniel Fassler on 1/26/16.
//  Copyright © 2016 matata. All rights reserved.
//

import UIKit
import Alamofire

class EditMyProfileViewController: UIViewController {
    
    @IBOutlet weak var lblUserName: UILabel!
    
    @IBOutlet weak var btnEditImage: UIButton!

    @IBOutlet weak var imgMyProfile: UIImageView!
    
    @IBOutlet weak var btnSave: UIButton!
    
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
                                
                let name = (resultDic.valueForKey("data")!.valueForKey("Name") as? String)!
                self.lblUserName.text = name
                
                if let url = NSURL(string: (resultDic.valueForKey("data")!.valueForKey("Picture") as? String)!) {
                    if let data = NSData(contentsOfURL: url){
                        self.imgMyProfile.contentMode = UIViewContentMode.ScaleAspectFill
                        self.imgMyProfile.image = UIImage(data: data)
                    }
                }
            }
        }
    }


    override func viewDidLayoutSubviews() {
        // make the profile image circular

        imgMyProfile.layer.cornerRadius = imgMyProfile.frame.size.width / 2.0
        imgMyProfile.clipsToBounds = true

        // make the edit image button circular
        btnEditImage.layer.cornerRadius = btnEditImage.frame.size.width / 2.0
        btnEditImage.clipsToBounds = true

        // stylize the save profile button
        btnSave.layer.cornerRadius = 20
        btnSave.clipsToBounds = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
