//
//  WellComeViewController.swift
//  commontech
//
//  Created by matata on 15/10/2015.
//  Copyright © 2015 matata. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI
import AddressBook
import AddressBookUI
import Alamofire

class WellComeViewController: UIViewController {
   
    @IBOutlet weak var openContactsList: UIButton!
    
    //Lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        openContactsList.hidden = true

        let defaults = NSUserDefaults.standardUserDefaults()
        let userId = defaults.stringForKey("guid")
        let status = defaults.stringForKey("status")

        
        if userId == nil || status != "approve"{
            
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("vcEnterPhone") as? EnterPhoneController
            self.navigationController?.pushViewController(vc!, animated: true)


        }
        else{
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("vcConnectionCollectionViewController") as? ConnectionCollectionViewController
            self.navigationController?.pushViewController(vc!, animated: true)
        }
        
        
   

  

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //Private methods
    
    func removeFbData() {
        
        FBSDKAccessToken.setCurrentAccessToken(nil)
    }

    //Action methods
    
    @IBAction func logOutBtn(sender: AnyObject) {
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject(nil, forKey: "UserId")
        removeFbData()
        //send to choose social network to connect with
        
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("vcChooseSocial") as? ChooseSocialViewController
        self.navigationController?.presentViewController(vc!, animated: true, completion:nil)
    }
    
    //    @IBAction func openContacts(sender: AnyObject) {
    //
    //            performSegueWithIdentifier("idSegueListContacts", sender: sender)
    //
    //    }
    //    @IBAction func openGroupOperations(sender: AnyObject) {
    //        performSegueWithIdentifier("idSegueGroupOperations", sender: sender)
    //
    //    }
}



