//
//  MyActivitiesVIewController.swift
//  commontech
//
//  Created by Daniel Fassler on 1/26/16.
//  Copyright © 2016 matata. All rights reserved.
//

import UIKit
import Alamofire

class MyActivitiesVIewController: UIViewController {

    @IBOutlet weak var imgProfileSmall: UIImageView!
    
    @IBOutlet weak var lblMyName: UILabel!
    
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
                        self.imgProfileSmall.contentMode = UIViewContentMode.ScaleAspectFill
                        self.imgProfileSmall.image = UIImage(data: data)
                    }
                }
            }
        }
    }

    override func viewDidLayoutSubviews() {
        // make the profile image circular
        imgProfileSmall.layer.cornerRadius = imgProfileSmall.frame.size.width / 2.0
        imgProfileSmall.clipsToBounds = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
