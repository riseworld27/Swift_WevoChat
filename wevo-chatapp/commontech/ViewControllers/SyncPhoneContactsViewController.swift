//
//  SyncPhoneContactsViewController.swift
//  commontech
//
//  Created by matata on 20/01/2016.
//  Copyright © 2016 matata. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI
import Alamofire

class SyncPhoneContactsViewController: UIViewController {
    @IBOutlet weak var navItem: WevoNavigationBar!

    @IBOutlet weak var activity: UIActivityIndicatorView!
    var contacts: [CNContact] = []
    var userContactsDetails = [UserContactsDetails]()

    func startActivity() {
        
        activity.hidden = false
        activity.startAnimating()
    }
    
    func stopActivity() {
        
        activity.hidden = true
        activity.stopAnimating()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        activity.hidden = true

        self.initNavBar()


    }
    func initNavBar() {
        self.navItem!.showHomeBtn()
        (self.navItem.rightBarButtonItems![0].customView as! UIButton).addTarget(self, action: "privetAction:", forControlEvents: UIControlEvents.TouchUpInside)
        (self.navItem.rightBarButtonItems![1].customView as! UIButton).addTarget(self, action: "myProfileAction:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func privetAction(sender:AnyObject) {
        self.showAlertView("Dive", message: "You can go to\"off line\" mode for browsing contacts in private mode")
        
    }
    func myProfileAction(sender:AnyObject) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("vcUserFacebookDetails") as? UserFacebookDetailsViewController
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    func showAlertView(title: String, message: String) {
        var diveTime = ""
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let firstAction = UIAlertAction(title: "30 min", style: .Default) { (alert: UIAlertAction!) -> Void in
            diveTime = "30"
        }
        let secondAction = UIAlertAction(title: "1 hour", style: .Default) { (alert: UIAlertAction!) -> Void in
            diveTime = "60"
        }
        let threeAction = UIAlertAction(title: "6 hours", style: .Default) { (alert: UIAlertAction!) -> Void in
            diveTime = "360"
        }
        let fourAction = UIAlertAction(title: "24 hours", style: .Default) { (alert: UIAlertAction!) -> Void in
            diveTime = "1440"
        }
        alert.addAction(firstAction)
        alert.addAction(secondAction)
        alert.addAction(threeAction)
        alert.addAction(fourAction)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    @IBAction func syncCOntacts(sender: AnyObject) {
        self.startActivity()
        AppDelegate.sharedDelegate().checkAccessStatus({ (accessGranted) -> Void in
            if accessGranted {
                
            }
        })
        self.loadContactsList()
        self.preperContactDetailsToDB()
    }
    func loadContactsList(){
        self.findContacts()
        
    }
    func findContacts()-> [CNContact]{
        
        let keysToFetch = [CNContactFormatter.descriptorForRequiredKeysForStyle(.FullName),CNContactGivenNameKey, CNContactFamilyNameKey, CNContactBirthdayKey, CNContactViewController.descriptorForRequiredKeys()] //
        let fetchRequest = CNContactFetchRequest( keysToFetch: keysToFetch)
        
        let contacts = [CNContact]()
        CNContact.localizedStringForKey(CNLabelPhoneNumberiPhone)
        fetchRequest.mutableObjects = false
        fetchRequest.unifyResults = true
        fetchRequest.sortOrder = .UserDefault
        
        let contactStoreID = CNContactStore().defaultContainerIdentifier()
        print("\(contactStoreID)")
        
        
        do {
            
            try CNContactStore().enumerateContactsWithFetchRequest(fetchRequest) { (let contact, let stop) -> Void in
                /////////////////////////
                if contact.phoneNumbers.count > 0 {
                    
                    self.contacts.append(contact)
                    
                }
                
            }
        } catch let e as NSError {
            print(e.localizedDescription)
        }
        
        return contacts
    }
    func preperContactDetailsToDB()
    {
        for contact in self.contacts{
            var phoneArr: [String] = []
            for phone in contact.phoneNumbers{
                let a = phone.value as! CNPhoneNumber
                let aString : String = a.stringValue
                
                
                phoneArr.append(aString)
            }
            var emailArr: [String] = []
            for email in contact.emailAddresses{
                emailArr.append(email.value as! String)
            }
            let userContact =  UserContactsDetails(identifier: contact.identifier, givenName: contact.givenName, familyName: contact.familyName, phoneNumbers: phoneArr, emailAddresses: emailArr)!
            
            self.userContactsDetails.append(userContact)
            
            
        }
        insertContactsToDB()
        
    }
    func insertContactsToDB(){
        let defaults = NSUserDefaults.standardUserDefaults()
        let Userkey = defaults.stringForKey("guid")
        if Userkey == nil{
            return
        }
        activity.hidden = false
        activity.startAnimating()
        for(var i = 0; i < self.userContactsDetails.count;i++){
            let parametersToSend = [
                "identifier": (self.userContactsDetails[i].identifier as? AnyObject)!,
                "givenName": (self.userContactsDetails[i].givenName as? AnyObject)!,
                "familyName": (self.userContactsDetails[i].familyName as? AnyObject)!,
                "phoneNumbers": (self.userContactsDetails[i].phoneNumbers as? AnyObject)!,
                "emailAddresses": (self.userContactsDetails[i].emailAddresses as? AnyObject)!,
                
            ]
            print(i)
            print(self.userContactsDetails[i].identifier)
            print(self.userContactsDetails[i].givenName)
            print(self.userContactsDetails[i].familyName)
            print(self.userContactsDetails[i].phoneNumbers)
            print(self.userContactsDetails[i].emailAddresses)
            
            let headers = ["Authorization": defaults.stringForKey("guid")!]
            
            Alamofire.request(.POST, "http://wevoapi.azurewebsites.net:80/api/users/"+defaults.stringForKey("guid")!+"/savecontactsDetails" , parameters:  parametersToSend, headers: headers).responseJSON { response in
                print(response)
                
            }
        }
        activity.hidden = true
        activity.stopAnimating()
        defaults.setObject("true", forKey: "isContacts")
        
        
        
        
    }
}
