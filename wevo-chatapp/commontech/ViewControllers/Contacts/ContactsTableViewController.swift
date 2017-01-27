//
//  ContactsTableViewController.swift
//  commontech
//
//  Created by matata on 19/10/2015.
//  Copyright © 2015 matata. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI
import Alamofire
class ContactsTableViewController: UIViewController {
    
    // MARK: screen Properties
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activity: UIActivityIndicatorView!

    var arrrayUser: [Users] = []

    // MARK: global properties
    @NSCopying var predicate: NSPredicate?
    var contacts: [CNContact] = []
    var userContactsDetails = [UserContactsDetails]()
    
    // MARK: override function
    override func viewDidLoad() {
        
        self.loadFacebookUsers()
        
        
        super.viewDidLoad()
        textField.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        //load first time all contacts
        self.findContacts()
        self.preperContactDetailsToDB()
        //self.checkIfDeviceExist()
    }
    func loadFacebookUsers(){
        let defaults = NSUserDefaults.standardUserDefaults()
        let UserId = defaults.stringForKey("guid")
        let headers = ["Authorization": defaults.stringForKey("guid")!]
        
        let postEndpoint = "http://wevoapi.azurewebsites.net:80/api/users/" + UserId! + "/allFacebook"
        Alamofire.request(.GET, postEndpoint, parameters:  nil, headers: headers).responseJSON { response in
            print(response)
            let resultDic : NSDictionary =  (response.result.value as? NSDictionary)!
            
            let resultArr : NSArray =  (resultDic.valueForKey("data") as? NSArray)!
            for item in resultArr {
                let users =  Users(userId: (item.valueForKey("userId") as? String)!, userName: (item.valueForKey("userName") as? String)!, userImage: (item.valueForKey("userImage") as? String)!, userPhone: (item.valueForKey("userPhone") as? String)!)!
                
                self.arrrayUser.append(users)
                
            }
            
            
        }
    }
    // MARK: functions
//    func checkIfDeviceExist()
//    {
//        //stringValue -> is the class build for only 1 string
//        let parametersToSend = [
//            "stringValue": (AppDelegate.sharedDelegate().checkIdentifierForVendor())
//        ]
//        let defaults = NSUserDefaults.standardUserDefaults()
//
//        Alamofire.request(.POST, "http://wevoapi.azurewebsites.net:80/api/UserDetails/Post", parameters:  parametersToSend).responseJSON { response in
//            print(response)
//            
//            // Store
//            defaults.setObject(AppDelegate.sharedDelegate().checkIdentifierForVendor(), forKey: "UDIDkey")
//            defaults.setObject(response.result.value, forKey: "Userkey")
//            
//            
//            // Receive
//            if let Userkey = defaults.stringForKey("Userkey")
//            {
//                print(Userkey)
//            }
//            self.findContacts()
//            self.preperContactDetailsToDB()
//            self.tableView.reloadData()
//        }
//    }
    func preperContactDetailsToDB()
    {
        for contact in self.contacts{
            var phoneArr: [String] = []
            for phone in contact.phoneNumbers{
                let a = phone.value as! CNPhoneNumber
                phoneArr.append(a.stringValue )
            }
            var emailArr: [String] = []
            for email in contact.emailAddresses{
                emailArr.append(email.value as! String)
            }
            
            
            let userContact =  UserContactsDetails(identifier: contact.identifier, givenName: contact.givenName, familyName: contact.familyName, phoneNumbers: phoneArr, emailAddresses: emailArr)!//, userImage: contact.thumbnailImageData)!
            
            
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
               // "Userkey": (Userkey as? AnyObject)!,
               // "userUDID": AppDelegate.sharedDelegate().checkIdentifierForVendor(),
                "identifier": (self.userContactsDetails[i].identifier as?AnyObject)!,
                "givenName": (self.userContactsDetails[i].givenName as? AnyObject)!,
                "familyName": (self.userContactsDetails[i].familyName as? AnyObject)!,
                "phoneNumbers": (self.userContactsDetails[i].phoneNumbers as? AnyObject)!,
                "emailAddresses": (self.userContactsDetails[i].emailAddresses as? AnyObject)!,
               // "userImage": (self.userContactsDetails[i].userImage as? AnyObject)!,
                
            ]
            let headers = ["Authorization": defaults.stringForKey("guid")!]

//            Alamofire.request(.POST, "http://wevoapi.azurewebsites.net:80/api/users/"+defaults.stringForKey("guid")!+"/savecontactsDetails" , parameters:  parametersToSend, headers: headers).responseJSON { response in
//                print(response)
//                
//            }
        }
        activity.hidden = true
        activity.stopAnimating()
        
        
        
        
    }
    // MARK: device function
    func findContacts () -> [CNContact]{
        
        let keysToFetch = [CNContactFormatter.descriptorForRequiredKeysForStyle(.FullName),CNContactGivenNameKey, CNContactFamilyNameKey, CNContactBirthdayKey, CNContactViewController.descriptorForRequiredKeys(),CNContactThumbnailImageDataKey] //
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

    //MARK: - User Actions
    func textFieldDidChange(textField: UITextField) {
        if let query = textField.text {
            findContactsWithName(query)
        }
    }
    //MARK: - Private Methods
    
    func findContactsWithName(name: String) {
        AppDelegate.sharedDelegate().checkAccessStatus({ (accessGranted) -> Void in
            if accessGranted {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    do {
                        let predicate: NSPredicate = CNContact.predicateForContactsMatchingName(name)
                        let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactBirthdayKey, CNContactViewController.descriptorForRequiredKeys()]
                        self.contacts = try AppDelegate.sharedDelegate().store.unifiedContactsMatchingPredicate(predicate, keysToFetch:keysToFetch)
                        for(var i = 0; i < self.contacts.count; i++){
                            print(self.contacts[i].givenName)
                            print(self.contacts[i].familyName)
                            print(self.contacts[i].departmentName)
                            print(self.contacts[i].phoneNumbers)
                            print(self.contacts[i].emailAddresses)
                            print(self.contacts[i].postalAddresses)

                        }

                        self.tableView.reloadData()
                    }
                    catch {
                        print("Unable to refetch the selected contact.")
                    }
                })
            }
        })
    }
}

//MARK: - UITableViewDataSource

extension ContactsTableViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let CellIdentifier = "ContactCell"
       // let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier)
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier, forIndexPath: indexPath) as! ContactsCell

        cell.contactName!.text = contacts[indexPath.row].givenName + " " + contacts[indexPath.row].familyName
        //TODO: isWevo check phone number??? 
        
        cell.isWevo!.text = contacts[indexPath.row].givenName + " " + contacts[indexPath.row].familyName
//        if let birthday = contacts[indexPath.row].birthday {
//            let formatter = NSDateFormatter()
//            formatter.dateStyle = NSDateFormatterStyle.LongStyle
//            formatter.timeStyle = .NoStyle
//            
           // cell!.detailTextLabel?.text = formatter.stringFromDate((birthday.date)!)
            
       // }
        return cell
    }
    
}

//MARK: - UITableViewDelegate

extension ContactsTableViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let controller = CNContactViewController(forContact: contacts[indexPath.row])
        controller.contactStore = AppDelegate.sharedDelegate().store
        controller.allowsEditing = false
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
}
