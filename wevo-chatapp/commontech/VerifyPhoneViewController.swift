//
//  VirfyPhoneViewController.swift
//  commontech
//
//  Created by matata on 22/12/2015.
//  Copyright © 2015 matata. All rights reserved.
//

import UIKit
import Alamofire
class VerifyPhoneViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var navItem: WevoNavigationBar!
    @IBOutlet weak var titleVerifyTxt: UILabel!
    @IBOutlet weak var enterVerifyCode: UITextField!
    @IBOutlet weak var btnSendCode: UIButton!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var lblCorrectCode: UILabel!
    
    func StartActivity()
    {
        activity.hidden = false
        activity.startAnimating()
    }
    func StopActivity()
    {
        activity.hidden = true
        activity.stopAnimating()
    }
    @IBAction func verifeyCodeAction(sender: AnyObject) {
        btnSendCode.hidden = true
        btnBack.hidden = true
        lblCorrectCode.hidden = true
        self.StartActivity()
        let isVal = self.validate(enterVerifyCode.text!)
        if !isVal{
            self.showAlertView("Error", message: "code number is not valid must be 4 digits")
            self.btnSendCode.hidden = false
            self.btnBack.hidden = false
            self.StopActivity()
            
            return
        }
        let parametersToSend = [
            "stringValue": (enterVerifyCode.text as? AnyObject)!
        ]
        let defaults = NSUserDefaults.standardUserDefaults()
        let postEndpoint = "http://wevoapi.azurewebsites.net:80/api/login/verfiyphonenumber"
        let headers = ["Authorization": defaults.stringForKey("guid")!]

        Alamofire.request(.POST, postEndpoint, parameters:  parametersToSend, headers: headers).responseJSON { response in
            print(response)
            if(response.result.value === NSNull() || response.result.value === nil){
                // self.showAlertView("Error", message: "Please enter the correct code")
                self.StopActivity()
                self.btnSendCode.hidden = false
                self.btnBack.hidden = false
                self.lblCorrectCode.hidden = false

                return
                
            }else{
                let resultDic : NSDictionary =  (response.result.value as? NSDictionary)!
                print(resultDic.valueForKey("data")!.valueForKey("guid"))
                let userData : NSDictionary =  (response.result.value as? NSDictionary)!
                if userData.valueForKey("data") === NSNull(){
                    // self.showAlertView("Error", message: "Please enter the correct code")
                    self.StopActivity()
                    self.btnSendCode.hidden = false
                    self.btnBack.hidden = false
                    self.lblCorrectCode.hidden = false
                    self.dismissKeyboard()

                    return
                }
                let guid = userData.valueForKey("data")!.valueForKey("guid")
                let phoneNumber = userData.valueForKey("data")!.valueForKey("phoneNumber")
                let status = userData.valueForKey("data")!.valueForKey("status")
                
                defaults.setObject(phoneNumber, forKey: "phoneNumber")
                defaults.setObject(guid, forKey: "guid")
                defaults.setObject(status, forKey: "status")
                
                let vc = self.storyboard?.instantiateViewControllerWithIdentifier("vcChooseSocial") as? ChooseSocialViewController
                self.navigationController?.pushViewController(vc!, animated: true)
                self.StopActivity()

            }
        }

    }
    
    @IBAction func backToEnterPhone(sender: AnyObject) {
        
        self.navigationController?.popViewControllerAnimated(true)
        
    }
    
    func validate(value: String) -> Bool {
        
        let CODE_REGEX = "^\\d{4}$"
        
        let codeTest = NSPredicate(format: "SELF MATCHES %@", CODE_REGEX)
        
        let result =  codeTest.evaluateWithObject(value)
        
        return result
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activity.hidden = true
        self.initNavBar()
        enterVerifyCode.delegate = self
        enterVerifyCode.keyboardType = UIKeyboardType.PhonePad
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
        self.navigationController?.navigationBarHidden = true

    }
    
    override func viewDidLayoutSubviews() {
        btnSendCode.layer.borderWidth = 1.0
        btnSendCode.layer.borderColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5).CGColor
        btnSendCode.clipsToBounds = true
    }

    func initNavBar() {
        
              self.navItem!.showBackLeftBtn()
                (self.navItem.leftBarButtonItem?.customView as! UIButton).addTarget(self, action: "backAction:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    func backAction(sender:AnyObject) {
        
        
        self.navigationController!.popViewControllerAnimated(true)
        
    }
    func showAlertView(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

  
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    

}
