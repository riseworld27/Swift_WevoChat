//
//  EnterPhoneController.swift
//  commontech
//
//  Created by matata on 09/11/2015.
//  Copyright © 2015 matata. All rights reserved.
//

import UIKit
import Alamofire
import CoreTelephony

class EnterPhoneController: UIViewController, UITextFieldDelegate {

    @IBOutlet var navItem: WevoNavigationBar!
    @IBOutlet weak var continueBtn: UIButton!
    // MARK : activity indecator
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
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

    @IBOutlet weak var txtAreaCode: UITextField!
    @IBOutlet weak var txtPhoneNumber: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
  
        let backButton = UIBarButtonItem(title: "", style: UIBarButtonItemStyle.Plain, target: navigationController, action: nil)
        navigationItem.leftBarButtonItem = backButton
        
        // self.navigationController?.navigationBarHidden = true

        // self.initNavBar()

        // Setup the Network Info and create a CTCarrier object
        let networkInfo = CTTelephonyNetworkInfo()
        let carrier = networkInfo.subscriberCellularProvider
        
        // Get carrier name
        var countryCode = carrier?.isoCountryCode
        if(countryCode == nil)
        {
            countryCode = "IL"
        }
        let codeArea = getCountryPhonceCode(((countryCode?.uppercaseString)! as String))
        txtAreaCode.text = codeArea
        self.StopActivity()

        txtPhoneNumber.delegate = self
        txtPhoneNumber.keyboardType = UIKeyboardType.PhonePad
        self.navigationController?.navigationBarHidden = true
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)

    }
    //Initialize back button on navigtion bar

    func initNavBar() {

      self.navItem!.showBackLeftBtn()
        (self.navItem.leftBarButtonItem?.customView as! UIButton).addTarget(self, action: "backAction:", forControlEvents: UIControlEvents.TouchUpInside)
   }
    
    override func viewDidAppear(animated: Bool) {
        continueBtn.hidden = false
    }
    
    override func viewDidLayoutSubviews() {
        continueBtn.layer.borderWidth = 1.0
        continueBtn.layer.borderColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5).CGColor
        continueBtn.clipsToBounds = true
        txtAreaCode.roundCorners([.TopLeft, .BottomLeft], radius: 7)
        txtAreaCode.clipsToBounds = true
        txtPhoneNumber.roundCorners([.TopRight, .BottomRight], radius: 7)
        txtPhoneNumber.clipsToBounds = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func backAction(sender:AnyObject) {
        
        
            self.navigationController!.popViewControllerAnimated(true)
        
    }
    func validate(value: String) -> Bool {
        
        let PHONE_REGEX = "^\\d{3}\\d{3}\\d{4}$"
        let PHONE_REGEX1 = "^\\d{10,14}$"
        
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX1)
        
        let result =  phoneTest.evaluateWithObject(value)
        
        return result
        
    }
    @IBAction func GenerateGuid(sender: AnyObject) {
        self.StartActivity()
        self.continueBtn.hidden = true
        let isVal = self.validate(txtPhoneNumber.text!)
        if !isVal{
            self.showAlertView("Error", message: "phone number is not valid must be 10 digits")
            self.continueBtn.hidden = false
            self.StopActivity()

            return
        }
        let phoneToSend = txtAreaCode.text! + "" + txtPhoneNumber.text!

        self.showAlertViewIsSure("Phone Number Verification", message:"Is this your correct number?\n" +
             phoneToSend + "\n" +
            "An SMS with your access code will be sent to this number", phoneNumber: phoneToSend)
          }
    @IBAction func userTappedBackground(sender: AnyObject) {
        view.endEditing(true)
    }

    func textField(textField: UITextField,
        shouldChangeCharactersInRange range: NSRange,
        replacementString string: String)
        -> Bool
    {
        if string.characters.count == 0 {
            return true
        }
        
        let currentText = textField.text ?? ""
        let prospectiveText = (currentText as NSString).stringByReplacingCharactersInRange(range, withString: string)
        
        switch textField {
            
            // Allow only upper- and lower-case vowels in this field,
            // and limit its contents to a maximum of 6 characters.

        case txtPhoneNumber:
            return prospectiveText.containsOnlyCharactersIn("+0123456789") &&
                prospectiveText.characters.count <= 14
            
  

        default:
            return true
        }
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    func getCountryPhonceCode (country : String) -> String
    {
        
        if country.characters.count == 2
        {
            let x : [String] = ["972", "IL",
                "93" , "AF",
                "355", "AL",
                "213", "DZ",
                "1"  , "AS",
                "376", "AD",
                "244", "AO",
                "1"  , "AI",
                "1"  , "AG",
                "54" , "AR",
                "374", "AM",
                "297", "AW",
                "61" , "AU",
                "43" , "AT",
                "994", "AZ",
                "1"  , "BS",
                "973", "BH",
                "880", "BD",
                "1"  , "BB",
                "375", "BY",
                "32" , "BE",
                "501", "BZ",
                "229", "BJ",
                "1"  , "BM",
                "975", "BT",
                "387", "BA",
                "267", "BW",
                "55" , "BR",
                "246", "IO",
                "359", "BG",
                "226", "BF",
                "257", "BI",
                "855", "KH",
                "237", "CM",
                "1"  , "CA",
                "238", "CV",
                "345", "KY",
                "236", "CF",
                "235", "TD",
                "56", "CL",
                "86", "CN",
                "61", "CX",
                "57", "CO",
                "269", "KM",
                "242", "CG",
                "682", "CK",
                "506", "CR",
                "385", "HR",
                "53" , "CU" ,
                "537", "CY",
                "420", "CZ",
                "45" , "DK" ,
                "253", "DJ",
                "1"  , "DM",
                "1"  , "DO",
                "593", "EC",
                "20" , "EG" ,
                "503", "SV",
                "240", "GQ",
                "291", "ER",
                "372", "EE",
                "251", "ET",
                "298", "FO",
                "679", "FJ",
                "358", "FI",
                "33" , "FR",
                "594", "GF",
                "689", "PF",
                "241", "GA",
                "220", "GM",
                "995", "GE",
                "49" , "DE",
                "233", "GH",
                "350", "GI",
                "30" , "GR",
                "299", "GL",
                "1"  , "GD",
                "590", "GP",
                "1"  , "GU",
                "502", "GT",
                "224", "GN",
                "245", "GW",
                "595", "GY",
                "509", "HT",
                "504", "HN",
                "36" , "HU",
                "354", "IS",
                "91" , "IN",
                "62" , "ID",
                "964", "IQ",
                "353", "IE",
                "972", "IL",
                "39" , "IT",
                "1"  , "JM",
                "81", "JP", "962", "JO", "77", "KZ",
                "254", "KE", "686", "KI", "965", "KW", "996", "KG",
                "371", "LV", "961", "LB", "266", "LS", "231", "LR",
                "423", "LI", "370", "LT", "352", "LU", "261", "MG",
                "265", "MW", "60", "MY", "960", "MV", "223", "ML",
                "356", "MT", "692", "MH", "596", "MQ", "222", "MR",
                "230", "MU", "262", "YT", "52","MX", "377", "MC",
                "976", "MN", "382", "ME", "1", "MS", "212", "MA",
                "95", "MM", "264", "NA", "674", "NR", "977", "NP",
                "31", "NL", "599", "AN", "687", "NC", "64", "NZ",
                "505", "NI", "227", "NE", "234", "NG", "683", "NU",
                "672", "NF", "1", "MP", "47", "NO", "968", "OM",
                "92", "PK", "680", "PW", "507", "PA", "675", "PG",
                "595", "PY", "51", "PE", "63", "PH", "48", "PL",
                "351", "PT", "1", "PR", "974", "QA", "40", "RO",
                "250", "RW", "685", "WS", "378", "SM", "966", "SA",
                "221", "SN", "381", "RS", "248", "SC", "232", "SL",
                "65", "SG", "421", "SK", "386", "SI", "677", "SB",
                "27", "ZA", "500", "GS", "34", "ES", "94", "LK",
                "249", "SD", "597", "SR", "268", "SZ", "46", "SE",
                "41", "CH", "992", "TJ", "66", "TH", "228", "TG",
                "690", "TK", "676", "TO", "1", "TT", "216", "TN",
                "90", "TR", "993", "TM", "1", "TC", "688", "TV",
                "256", "UG", "380", "UA", "971", "AE", "44", "GB",
                "1", "US", "598", "UY", "998", "UZ", "678", "VU",
                "681", "WF", "967", "YE", "260", "ZM", "263", "ZW",
                "591", "BO", "673", "BN", "61", "CC", "243", "CD",
                "225", "CI", "500", "FK", "44", "GG", "379", "VA",
                "852", "HK", "98", "IR", "44", "IM", "44", "JE",
                "850", "KP", "82", "KR", "856", "LA", "218", "LY",
                "853", "MO", "389", "MK", "691", "FM", "373", "MD",
                "258", "MZ", "970", "PS", "872", "PN", "262", "RE",
                "7", "RU", "590", "BL", "290", "SH", "1", "KN",
                "1", "LC", "590", "MF", "508", "PM", "1", "VC",
                "239", "ST", "252", "SO", "47", "SJ",
                "963","SY",
                "886",
                "TW", "255",
                "TZ", "670",
                "TL","58",
                "VE","84",
                "VN",
                "284", "VG",
                "340", "VI",
                "678","VU",
                "681","WF",
                "685","WS",
                "967","YE",
                "262","YT",
                "27","ZA",
                "260","ZM",
                "263","ZW"]
            var keys = [String]()
            var values = [String]()
            let whitespace = NSCharacterSet.decimalDigitCharacterSet()
            
            //let range = phrase.rangeOfCharacterFromSet(whitespace)
            for i in x {
                // range will be nil if no whitespace is found
                if  (i.rangeOfCharacterFromSet(whitespace) != nil) {
                    values.append(i)
                }
                else {
                    keys.append(i)
                }
            }
            let countryCodeListDict = NSDictionary(objects: values as [String], forKeys: keys as [String])
            if  (countryCodeListDict[country] != nil) {
                return countryCodeListDict[country] as! String
            } else
            {
                return ""
            }
        }
        else
        {
            return ""
        }
    }
    func showAlertView(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    func showAlertViewIsSure(title: String, message: String, phoneNumber: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let editAction = UIAlertAction(title: "Edit", style: .Default) { (alert: UIAlertAction!) -> Void in
            self.StopActivity()
            self.continueBtn.hidden = false
        }

        let okAction = UIAlertAction(title: "OK", style: .Default) { (alert: UIAlertAction!) -> Void in
            //the parameters that send to server for generation of Guid
            let parametersToSend = [
                //  "Guid": (Guid as? AnyObject)!,
                "stringValue": phoneNumber
            ]
            
            let postEndpoint = "http://wevoapi.azurewebsites.net:80/api/login/userphonenumber"
            let defaults = NSUserDefaults.standardUserDefaults()
            
            Alamofire.request(.POST, postEndpoint, parameters:  parametersToSend).responseJSON { response in
                print(response)
                
                let userData : NSDictionary =  (response.result.value as? NSDictionary)!
                
                if(userData.valueForKey("data") === NSNull() )
                {
                    self.showAlertView("error", message: userData.valueForKey("error")! as! String)
                    self.continueBtn.hidden = false
                    
                    self.StopActivity()
                    
                    return;
                }
                else{
                    let guid = userData.valueForKey("data")!.valueForKey("guid")
                    let phoneNumber = userData.valueForKey("data")!.valueForKey("phoneNumber")
                    let status = userData.valueForKey("data")!.valueForKey("status")
                    
                    defaults.setObject(phoneNumber, forKey: "phoneNumber")
                    defaults.setObject(guid, forKey: "guid")
                    defaults.setObject(status, forKey: "status")
                    
                    
                    defaults.setObject("false", forKey: "isGoogleUser")
                    defaults.setObject("false", forKey: "isFacebookUser")
                    defaults.setObject("false", forKey: "isInstagramUser")
                    defaults.setObject("false", forKey: "isYoutubeUser")
                    defaults.setObject("false", forKey: "isContacts")
                    
                    self.StopActivity()
                    //TODO : need to send to confirmation screen
                    //                        if let navController = self.navigationController {
                    //                            navController.popViewControllerAnimated(true)
                    //                        }
                    //should always send to social page
                    // if(FBSDKAccessToken.currentAccessToken() != nil) {
                    //    print(FBSDKAccessToken.currentAccessToken())
                    let vc = self.storyboard?.instantiateViewControllerWithIdentifier("vcVerifyCode") as? VerifyPhoneViewController
                    self.navigationController?.pushViewController(vc!, animated: true)
                    
                    //    }
                }
            }

        }
        alert.addAction(editAction)
        alert.addAction(okAction)

        self.presentViewController(alert, animated: true, completion: nil)
    }
}
