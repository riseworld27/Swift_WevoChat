//
//  UserCollectionViewController.swift
//  commontech
//
//  Created by matata on 12/01/2016.
//  Copyright © 2016 matata. All rights reserved.
//

import UIKit
import QuartzCore
import Alamofire
import Contacts
import ContactsUI
import NMPopUpViewSwift

class ConnectionCollectionViewController: UIViewController {
    @IBOutlet weak var activity: UIActivityIndicatorView!
    var isWiggling: Bool { return _isWiggling }
    var popViewController : PopUpInvateViewController!
    var addToGroup = false
    private var _isWiggling = false
    private var startLocation: CGPoint!
    private var touchedCell: UserCell!
    private var location: CGPoint!
    @IBOutlet weak var backImage: UIImageView!
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var viewAddUsers: UIView!
    @IBOutlet weak var addUsersCollection: UICollectionView!
    enum MODE {
        case Normal, CreateGrp
    }

    let TAG_ARROWS = 99, TAG_DIM = 200, TAG_CELL = 121, TAG_ITEM = 150
    let SWIPE_THRESHOLD: CGFloat = 25.0
    let SWIPE_DISTANCE: CGFloat = 25.0
    
    var down, up, left, right: UISwipeGestureRecognizer!
    
    func StartActivity()
    {
        activity.hidden = false
        activity.startAnimating()
        self.collectionView.bringSubviewToFront(self.activity)
    }
    func StopActivity()
    {
        activity.hidden = true
        activity.stopAnimating()
        self.collectionView.sendSubviewToBack(self.activity)

    }
    @IBOutlet weak var collectionView: UICollectionView!
    
    var isActive : Bool = false
    let identifier = "UserCollectionCell"
    var arrayConnection: [Connection] = []
        var arrayAddUsers: [Connection] = []
        let identifierAdd = "AddUserCell"
    var darkScreen: UIView!
    var imgArrows: UIImageView!
    
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var navItem: WevoNavigationBar!
    
    @IBOutlet weak var createGroupIcon: UITabBarItem!
    @IBOutlet weak var searchIcon: UITabBarItem!
    @IBOutlet weak var goChatIcon: UITabBarItem!
    
    var contacts: [CNContact] = []
    var contactsNoImage: [CNContact] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        let defaults = NSUserDefaults.standardUserDefaults()
        let userId = defaults.stringForKey("guid")
        let status = defaults.stringForKey("status")
        
        if userId == nil || status != "approve"{
            
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("vcEnterPhone") as? EnterPhoneController
            self.navigationController?.pushViewController(vc!, animated: true)
            
            return
        }
        
        self.StartActivity()
        loadConnection()
        
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.blackColor().CGColor
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        self.navigationController?.navigationBar.layer.shadowRadius = 3.0
        self.navigationController?.navigationBar.layer.shadowOpacity = 0.0
        
        imgArrows = UIImageView(image: UIImage(named: "wevo_4directions"))
        imgArrows.contentMode = UIViewContentMode.ScaleAspectFill
        imgArrows.center.y -= 10
        
        // Set spacing between contact cells according to device screen scale
        // So 3 cells appear in one row on all devices
        let spacingInset: CGFloat = 5.0 * UIScreen.mainScreen().scale
        
        collectionView.contentInset = UIEdgeInsets(top: 20, left: spacingInset, bottom: 0, right: spacingInset)

        addUsersCollection.contentInset = UIEdgeInsets(top: 10, left: 15, bottom: 15, right: 15)

        // self.tabBar.tintColor = UIColor.whiteColor()
        self.tabBar.layer.masksToBounds = false
        self.tabBar.layer.shadowColor = UIColor.blackColor().CGColor
        self.tabBar.layer.shadowOffset = CGSize(width: 0.0, height: -10.0)
        self.tabBar.layer.shadowOpacity = 0.7
        self.tabBar.layer.shadowRadius = 15
        let tabBarItem1 = tabBar.items![0] as UITabBarItem
        let tabBarItem2 = tabBar.items![1] as UITabBarItem
        let tabBarItem3 = tabBar.items![2] as UITabBarItem
        tabBarItem1.selectedImage = UIImage(named: "wevo_chat_massages")?.imageWithRenderingMode(.AlwaysOriginal)
        tabBarItem2.selectedImage = UIImage(named: "wevo_icon_create_group")?.imageWithRenderingMode(.AlwaysOriginal)
        tabBarItem3.selectedImage = UIImage(named: "wevo_icon_search")?.imageWithRenderingMode(.AlwaysOriginal)
        
        for item in self.tabBar.items! as [UITabBarItem] {
            if let image = item.image {
                item.image = image.imageWithColor(UIColor.whiteColor()).imageWithRenderingMode(.AlwaysOriginal)
                
            }
        }
        
        self.initNavBar()
        
        // Tap recognizer for collection view background
//        let tap = UITapGestureRecognizer(target: self, action : "handleTap:")
//        tap.numberOfTapsRequired = 1
        self.collectionView.backgroundView = UIView(frame:self.collectionView.bounds)
        // self.collectionView.backgroundView!.addGestureRecognizer(tap)
        
    }
    func loadContactsPhone(){
        findContacts()
        let resultArr : NSArray =  (self.contacts)
        for item in resultArr {
            var tempPhone = ""
            if (item.isKeyAvailable(CNContactPhoneNumbersKey)) {
                for phoneNumber:CNLabeledValue in item.phoneNumbers {
                    let a = phoneNumber.value as! CNPhoneNumber
                    print("\(a.stringValue)")
                    tempPhone = a.stringValue
                }
            }
            let users =  Connection(
                id: item.identifier ,//=== NSNull() ? "": (item.valueForKey("id") as? String)!,
                type: "ghost",//.valueForKey("type") === NSNull() ? "": (item.valueForKey("type") as? String)!,
                name: (item.givenName!)! + " " + (item.lastName!)!,//valueForKey("name") === NSNull() ? "": (item.valueForKey("name") as? String)!,
                image: "",
                phone: tempPhone,
                selected: false,
                hightlight: false,
                imageData: item.imageData
                )!
            
            self.arrayConnection.append(users)
            
        }
        self.do_collection_refresh();
        
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
                //load only contacts with phone number
                if(contact.imageData != nil && contact.phoneNumbers.count > 0){
                    self.contacts.append(contact)
                }
                else if (contact.phoneNumbers.count > 0){
                    self.contactsNoImage.append(contact)
                    
                }

                
            }
        } catch let e as NSError {
            print(e.localizedDescription)
        }
        self.contacts.appendContentsOf(self.contactsNoImage) // Swift 2

        return self.contacts
        
    }
    override func viewDidAppear(animated: Bool) {
        // Set the navigation controller's default slide animation to left
        self.navigationController?.setDirection(ViewAnimator.SlideDirection.Left)
    }
    
    override func viewDidLayoutSubviews() {
        self.tabBar.roundCorners([.TopLeft,.TopRight], radius: 7)
    }
    
    func initNavBar() {
        self.navItem!.showHomeBtn()
        (self.navItem.rightBarButtonItems![0].customView as! UIButton).addTarget(self, action: "privetAction:", forControlEvents: UIControlEvents.TouchUpInside)
        (self.navItem.rightBarButtonItems![1].customView as! UIButton).addTarget(self, action: "myProfileAction:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func privetAction(sender:AnyObject) {
        self.showAlertView("Dive", message: "You can go to\"off line\" mode for browsing contacts in private mode")
        
    }
    func myProfileAction(sender:AnyObject) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("vcMyProfile") as? MyProfileViewController
        self.navigationController?.setDirection(ViewAnimator.SlideDirection.Up)
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
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        if item.tag == 1
        {
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("vcChatRoomViewController") as? ChatRoomViewController
            self.navigationController?.pushViewController(vc!, animated: true)
        }
        else if item.tag == 2{

            addToGroup = true
            self.openContainer()
            //            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("vcCreateGroup") as? CreateGroupController
            //            self.navigationController?.pushViewController(vc!, animated: true)

        }
        else if item.tag == 3{
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("vcGroupsViewController") as? GroupsController
            self.navigationController?.pushViewController(vc!, animated: true)
            
        }
    }
    ///
    func loadConnection()
    {
        let defaults = NSUserDefaults.standardUserDefaults()
        let UserId = defaults.stringForKey("guid")
        let headers = ["Authorization": defaults.stringForKey("guid")!]
        
//        let postEndpoint = "http://wevoapi.azurewebsites.net:80/api/connection/" + UserId!
//        Alamofire.request(.GET, postEndpoint, parameters:  nil, headers: headers).responseJSON { response in
//            print(response)
//            let resultDic : NSDictionary =  (response.result.value as? NSDictionary)!
//            if resultDic.valueForKey("data") === NSNull(){
//                let alert = UIAlertController(title: "Error", message: "Data is null", preferredStyle: UIAlertControllerStyle.Alert)
//                alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
//                
//                self.presentViewController(alert, animated: true, completion: nil)
//            }else{
//                let resultArr : NSArray =  (resultDic.valueForKey("data") as? NSArray)!
//                for item in resultArr {
//                    let users =  Connection(
//                        id: item.valueForKey("id") === NSNull() ? "": (item.valueForKey("id") as? String)!,
//                        type: item.valueForKey("type") === NSNull() ? "": (item.valueForKey("type") as? String)!,
//                        name: item.valueForKey("name") === NSNull() ? "": (item.valueForKey("name") as? String)!,
//                        image: item.valueForKey("image") === NSNull() ? "": (item.valueForKey("image") as? String)!,
//                        phone: item.valueForKey("phone") === NSNull() ? "": (item.valueForKey("phone") as? String)!,
//                        selected: false,
//                        hightlight: false,
//                        imageData: NSData()
//                        )!
//                    
//                    self.arrayConnection.append(users)
//                    
//                }
//            }
//            self.do_collection_refresh();
//            //load phone connection only after users and groups
//            self.loadContactsPhone()
//        }
        
        var isUsers = false
        var isGroups = false
        let postEndpoint = "http://wevoapi.azurewebsites.net:80/api/connection/" + UserId! + "/users"
        Alamofire.request(.GET, postEndpoint, parameters:  nil, headers: headers).responseJSON { response in
            print(response)
            let resultDic : NSDictionary =  (response.result.value as? NSDictionary)!
            if resultDic.valueForKey("data") === NSNull(){
                let alert = UIAlertController(title: "Error", message: "Data is null", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
                
                self.presentViewController(alert, animated: true, completion: nil)
            }else{
                let resultArr : NSArray =  (resultDic.valueForKey("data") as? NSArray)!
                for item in resultArr {
                    let users =  Connection(
                        id: item.valueForKey("id") === NSNull() ? "": (item.valueForKey("id") as? String)!,
                        type: item.valueForKey("type") === NSNull() ? "": (item.valueForKey("type") as? String)!,
                        name: item.valueForKey("name") === NSNull() ? "": (item.valueForKey("name") as? String)!,
                        image: item.valueForKey("image") === NSNull() ? "": (item.valueForKey("image") as? String)!,
                        phone: item.valueForKey("phone") === NSNull() ? "": (item.valueForKey("phone") as? String)!,
                        selected: false,
                        hightlight: false,
                        imageData: NSData()
                        )!
                    
                    self.arrayConnection.append(users)
                    
                }
            }
            isUsers = true
            self.do_collection_refresh();
            
            //load phone connection only after users and groups
         //   self.loadContactsPhone()
        }
        let postEndpoint1 = "http://wevoapi.azurewebsites.net:80/api/connection/" + UserId! + "/groups"
        Alamofire.request(.GET, postEndpoint1, parameters:  nil, headers: headers).responseJSON { response in
            print(response)
            let resultDic : NSDictionary =  (response.result.value as? NSDictionary)!
            if resultDic.valueForKey("data") === NSNull(){
                let alert = UIAlertController(title: "Error", message: "Data is null", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
                
                self.presentViewController(alert, animated: true, completion: nil)
            }else{
                let resultArr : NSArray =  (resultDic.valueForKey("data") as? NSArray)!
                for item in resultArr {
                    let users =  Connection(
                        id: item.valueForKey("id") === NSNull() ? "": (item.valueForKey("id") as? String)!,
                        type: item.valueForKey("type") === NSNull() ? "": (item.valueForKey("type") as? String)!,
                        name: item.valueForKey("name") === NSNull() ? "": (item.valueForKey("name") as? String)!,
                        image: item.valueForKey("image") === NSNull() ? "": (item.valueForKey("image") as? String)!,
                        phone: item.valueForKey("phone") === NSNull() ? "": (item.valueForKey("phone") as? String)!,
                        selected: false,
                        hightlight: false,
                        imageData: NSData()
                        )!
                    
                    self.arrayConnection.append(users)
                    
                }
            }
            self.do_collection_refresh();
            isGroups = true
        

        }
        let delay = 4.5 * Double(NSEC_PER_SEC)
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue()) {
              self.loadContactsPhone()

        }
    }
    
    func do_collection_refresh()
    {
        //{SN} check if improve scroll collection
     //   dispatch_async(dispatch_get_main_queue(), {
            self.collectionView.reloadData()
              self.StopActivity()
            
            return
       // })
     
    }
    
    
}

extension ConnectionCollectionViewController : UICollectionViewDataSource {
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.isEqual(self.collectionView) {
            return arrayConnection.count
        }
        
        if collectionView.isEqual(self.addUsersCollection) {
            return arrayAddUsers.count
        }
        
        return 0
    }
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if collectionView.isEqual(self.collectionView) {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(identifier,forIndexPath:indexPath) as! UserCell
            var isGhost = false
            
            cell.photoImage.clipsToBounds = true
            
            let conn = self.arrayConnection[indexPath.row]
            if let label = cell.name{
                label.text = conn.name
            }
            //  cell.cornerViewCOntainer.setHeight(50)
            //  cell.cornerViewCOntainer.setWidth(50)
            if let url = cell.photoImage{
                if conn.image == "empty"
                {
                    var imageName = ""
                    url.contentMode = UIViewContentMode.ScaleAspectFill
                    if conn.type == "group" {
                        imageName = "wevo_group_default_icon_big"
                    } else {
                        imageName = "wevo_chat_user_non.png"
                    }
                    url.image = UIImage(named: imageName)
                }
                    
                else if conn.imageData != nil && conn.image == ""
                {
                    let pictureURL = conn.imageData
                    
                    if let data = pictureURL{
                        url.contentMode = UIViewContentMode.ScaleAspectFill
                        url.image = UIImage(data: data)
                    }
                    isGhost = true
                    
                    
                }
                else if conn.imageData == nil && conn.image == ""{
                    var imageName = ""
                    imageName = "wevo_chat_user_non.png"
                    
                    url.image = UIImage(named: imageName)
                    isGhost = true
                    
                }
                else{
                    let pictureURL = NSURL(string:conn.image)
                    isGhost = false
//
//                    
//                    if let data = NSData(contentsOfURL: pictureURL!){
//                        
//                        url.contentMode = UIViewContentMode.ScaleAspectFill
//                        url.image = UIImage(data: data)
//                    }

                    url.contentMode = UIViewContentMode.ScaleAspectFill

                    if conn.type == "group" {
                        url.sd_setImageWithURL(pictureURL, placeholderImage: UIImage(named: "wevo_group_default_icon_big"))
                    } else {
                        url.sd_setImageWithURL(pictureURL, placeholderImage: UIImage(named: "wevo_chat_user_non.png"))
                    }
                }
                
            }
            //TODO: generate hottenest border algoritem
            if conn.type != nil{
                if conn.type == "group"{
                    //                cell.cornerViewCOntainer.layer.borderColor = UIColor.redColor().CGColor
                    //                cell.cornerViewCOntainer.layer.borderWidth = 5
                    cell.cornerViewCOntainer.layer.cornerRadius = 8
                    cell.photoImage.layer.cornerRadius = 8
                    cell.cornerViewCOntainer.clipsToBounds = false
                    cell.cornerViewCOntainer.layer.shadowOffset = CGSize(width: 0, height: 6)
                    cell.cornerViewCOntainer.layer.shadowOpacity = 0.7
                    cell.cornerViewCOntainer.layer.shadowRadius = 2
                }else {
                    cell.cornerViewCOntainer.layer.borderColor = UIColor.clearColor().CGColor
                    cell.cornerViewCOntainer.layer.borderWidth = 0
                    cell.cornerViewCOntainer.layer.cornerRadius = 0
                    cell.photoImage.layer.cornerRadius = cell.photoImage.frame.size.width / 2
                    cell.photoImage.clipsToBounds = true
                    cell.cornerViewCOntainer.clipsToBounds = false
                    cell.cornerViewCOntainer.layer.shadowOffset = CGSize(width: 0, height: 6)
                    cell.cornerViewCOntainer.layer.shadowOpacity = 0.7
                    cell.cornerViewCOntainer.layer.shadowRadius = 2
                }
            }
            if isGhost{
                cell.tag = 1
                
            }else{
                cell.tag = 2
                
                down = UISwipeGestureRecognizer(target: self, action: Selector("swipeToChat:"))
                down.direction = UISwipeGestureRecognizerDirection.Down
                //         cell.addGestureRecognizer(down)
                
                up = UISwipeGestureRecognizer(target: self, action: Selector("swipeToProfile:"))
                up.direction = UISwipeGestureRecognizerDirection.Up
                //         cell.addGestureRecognizer(up)
                
                left = UISwipeGestureRecognizer(target: self, action: Selector("swipeToTrends:"))
                left.direction = UISwipeGestureRecognizerDirection.Left
                //         cell.addGestureRecognizer(left)
                
                right = UISwipeGestureRecognizer(target: self, action: Selector("swipeToDiscover:"))
                right.direction = UISwipeGestureRecognizerDirection.Right
                //         cell.addGestureRecognizer(right)
            }
            let twoSecClick = UILongPressGestureRecognizer(target: self, action: Selector("bringItemToFront:"))
            cell.addGestureRecognizer(twoSecClick)
            
            if conn.selected == true{
                //            cell.photoImage.alpha = 1
                //            cell.cornerViewCOntainer.alpha = 1
                //            cell.name.alpha = 1
                //
                //            let imgArrows = UIImageView(image: UIImage(named: "wevo_4directions"))
                //            imgArrows.contentMode = UIViewContentMode.ScaleAspectFill
                //            imgArrows.bounds.size = cell.bounds.size
                //            imgArrows.tag = TAG_ARROWS
                //            
                //            cell.addSubview(imgArrows)
                //            cell.sendSubviewToBack(imgArrows)
                
                // cell.backgroundColor = UIColor(patternImage: UIImage(named: "wevo_4directions")!)
                
            }
            else if conn.selected == false && self.isActive == false{
                //            cell.photoImage.alpha = 1
                //            cell.cornerViewCOntainer.alpha = 1
                //            cell.name.alpha = 1
                
            }else if self.isActive{
                //            cell.photoImage.alpha = 1
                //            cell.cornerViewCOntainer.alpha = 1
                //            cell.name.alpha = 1
            }
            ///////
            
            return cell
            
        } else if collectionView.isEqual(addUsersCollection) {
            
            let cellAdd = collectionView.dequeueReusableCellWithReuseIdentifier(identifierAdd,forIndexPath:indexPath) as! AddToGroupCell
            
            cellAdd.imgAddUser.layer.cornerRadius = cellAdd.imgAddUser.frame.size.width / 2
            cellAdd.imgAddUser.clipsToBounds = true
            
            let connAdd = self.arrayAddUsers[indexPath.row]
            
            if let url = cellAdd.imgAddUser {
                let pictureURL = NSURL(string:connAdd.image)
                
//                if let data = NSData(contentsOfURL: pictureURL!){
//                    url.contentMode = UIViewContentMode.ScaleAspectFill
//                    url.image = UIImage(data: data)
//                }

                url.contentMode = UIViewContentMode.ScaleAspectFill
                url.sd_setImageWithURL(pictureURL, placeholderImage: UIImage(named: "wevo_chat_user_non.png"))
            }
            
            return cellAdd
        }
        return UICollectionViewCell()
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        let headerView: UICollectionReusableView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "HeaderView", forIndexPath: indexPath)
        
        return headerView
    }
    
    func bringItemToFront (gestureRecognizer: UILongPressGestureRecognizer)
    {
        
        location = gestureRecognizer.locationInView(self.collectionView)
        
        if gestureRecognizer.state == .Began {

            self.StartActivity()
            
            startLocation = gestureRecognizer.locationInView(self.collectionView)
            let swipedIndexPath = self.collectionView.indexPathForItemAtPoint(startLocation)!
            
            guard let cell = collectionView.cellForItemAtIndexPath(swipedIndexPath) as? UserCell else {print("error")
                return
            }
            
            touchedCell = cell
            
            self.collectionView.scrollEnabled = false
            self.isActive = true
            for(var i = 0; i < self.arrayConnection.count; i++)
            {
                self.arrayConnection[i].selected = false
                self.arrayConnection[i].hightlight = false
            }
            self.arrayConnection[swipedIndexPath.row].selected = true
            self.arrayConnection[swipedIndexPath.row].hightlight = true
          
            // Take a snapshot of the selected cell and add to dimming view
            let center = self.collectionView.convertPoint(cell.center, toView: self.collectionView.superview)
            
            let cellSnapshot = cell.snapshotViewAfterScreenUpdates(false)
            
            cellSnapshot.center = center
            cellSnapshot.tag = TAG_CELL
            
            self.dimViewWithItem(cellSnapshot)
                
            self.StopActivity()

        } else if gestureRecognizer.state == .Changed {
            
            let translateX: CGPoint = CGPoint(x: location.x-startLocation.x, y: 0)
            let translateY: CGPoint = CGPoint(x: 0, y: location.y-startLocation.y)
            
            if translateX.x > SWIPE_DISTANCE && abs(translateY.y) < SWIPE_THRESHOLD {
                print("swipe right")
                // self.removeDimCover()
                gestureRecognizer.enabled = false
                self.swipeToDiscover(startLocation)
            } else if translateX.x < -SWIPE_DISTANCE && abs(translateY.y) < SWIPE_THRESHOLD {
                print("swipe left")
                // self.removeDimCover()
                gestureRecognizer.enabled = false
                self.swipeToTrends(startLocation)
            } else if translateY.y > SWIPE_DISTANCE && abs(translateX.x) < SWIPE_THRESHOLD {
                print("swipe down")
                // self.removeDimCover()
                self.swipeToChat(startLocation)
                gestureRecognizer.enabled = false
            } else if translateY.y < -SWIPE_DISTANCE && abs(translateX.x) < SWIPE_THRESHOLD {
                print("swipe up")
                // self.removeDimCover()
                gestureRecognizer.enabled = false
                self.swipeToProfile(startLocation)
            }
            
            // print("gesture changed")
            
        } else if gestureRecognizer.state == .Cancelled {
            print("gesture cancelled")
            self.removeDimCover()
            
            let twoSecClick = UILongPressGestureRecognizer(target: self, action: Selector("bringItemToFront:"))
            touchedCell.addGestureRecognizer(twoSecClick)

            
        } else if gestureRecognizer.state == .Ended {
            print("gesture ended")
            self.removeDimCover()

            let twoSecClick = UILongPressGestureRecognizer(target: self, action: Selector("bringItemToFront:"))
            touchedCell.addGestureRecognizer(twoSecClick)

        }

    }
    
    func swipeToChat(point: CGPoint) {
        // Deal with swipe
        self.StartActivity()
        // let location : CGPoint = gestureRecognizer.locationInView(self.collectionView)
        let swipedIndexPath:NSIndexPath = self.collectionView.indexPathForItemAtPoint(point)!
        let swipedcell:UICollectionViewCell = self.collectionView.cellForItemAtIndexPath(swipedIndexPath)!
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let UserId = defaults.stringForKey("guid")
        let headers = ["Authorization": defaults.stringForKey("guid")!]
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("vcChatViewController") as? ChatViewController

        self.navigationController?.setDirection(ViewAnimator.SlideDirection.Down)

        if self.arrayConnection[swipedIndexPath.row].type == "group"{
            vc!.passedChatId = self.arrayConnection[swipedIndexPath.row].id
            vc!.passedType = self.arrayConnection[swipedIndexPath.row].type
            
            self.navigationController?.pushViewController(vc!, animated: true)

        }else{
    
            let parametersToSend = [
                //  "Guid": (Guid as? AnyObject)!,
                "stringValue": self.arrayConnection[swipedIndexPath.row].id!
            ]
            let postEndpoint = "http://wevoapi.azurewebsites.net:80/api/chat/" + UserId!
            
            Alamofire.request(.POST, postEndpoint, parameters:  parametersToSend, headers: headers).responseJSON { response in
                print(response)
                let resultDic : NSDictionary =  (response.result.value as? NSDictionary)!
                if resultDic.valueForKey("data") === NSNull(){
                    let alert = UIAlertController(title: "Error", message: "Data is null", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
                    
                    self.presentViewController(alert, animated: true, completion: nil)
                }else{
                    
                    
                    print(swipedIndexPath.row)
                    print(swipedcell)
                   // let defaults = NSUserDefaults.standardUserDefaults()
                   // let Userkey = defaults.stringForKey("guid")
                    let vc = self.storyboard?.instantiateViewControllerWithIdentifier("vcChatViewController") as? ChatViewController
                    if self.arrayConnection[swipedIndexPath.row].type == "user"
                    {
                        vc!.passedChatId = resultDic.valueForKey("data")! as! String
                        vc!.passedFreindId = self.arrayConnection[swipedIndexPath.row].id
                        
                    }
                    vc!.passedType = self.arrayConnection[swipedIndexPath.row].type
                    self.StopActivity()
                    // self.removeDimCover()
                                        
                    self.navigationController?.pushViewController(vc!, animated: true)
                    
                }
            }
        }

    }
    func swipeToProfile(point: CGPoint) {
        // Deal with swipe
        // let location : CGPoint = gestureRecognizer.locationInView(self.collectionView)
        let swipedIndexPath:NSIndexPath = self.collectionView.indexPathForItemAtPoint(point)!
        let swipedcell:UICollectionViewCell = self.collectionView.cellForItemAtIndexPath(swipedIndexPath)!
        
        print(swipedIndexPath.row)
        print(swipedcell)
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("vcUserFacebookDetails") as? UserFacebookDetailsViewController
        
        vc!.userId = self.arrayConnection[swipedIndexPath.row].id
        vc!.isMe = false
        
        self.navigationController?.setDirection(ViewAnimator.SlideDirection.Up)
        
        // self.removeDimCover()
        
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    func swipeToTrends(point: CGPoint) {
        // Swipe left to trends
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("TrendsStub") 
        self.navigationController?.setDirection(ViewAnimator.SlideDirection.Left)
        // self.removeDimCover()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    func swipeToDiscover(point: CGPoint) {
        // Swipe right to discover
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("DiscoverStub")
        self.navigationController?.setDirection(ViewAnimator.SlideDirection.Right)
        // self.removeDimCover()
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    func animatedCollection(toDefualt: Bool ){
       let cells = self.collectionView.visibleCells()
      //  let conn = self.arrayConnection[indexPath.row]

        ///
      //  stopWiggle()
        for i in cells {
            let cell: UserCell = i as! UserCell
            
            if cell.selected == true && toDefualt{
                cell.photoImage.alpha = 1
                cell.cornerViewCOntainer.alpha = 1
                cell.name.alpha = 0
                
                 cell.backgroundColor = UIColor(patternImage: UIImage(named: "wevo_4directions")!)
              //  addWiggleAnimationToCell(cell)
                
                
            }
            else if cell.selected == true && toDefualt == false{
                cell.photoImage.alpha = 1
                cell.cornerViewCOntainer.alpha = 1
                cell.name.alpha = 1
            }

            else if i.selected == false && self.isActive == false{
                cell.photoImage.alpha = 1
                cell.cornerViewCOntainer.alpha = 1
                cell.name.alpha = 1

            }else if self.isActive{
                cell.photoImage.alpha = 1
                cell.cornerViewCOntainer.alpha = 1
                cell.name.alpha = 1
            }
        }
        self.StopActivity()
        ///
    }
    private func stopWiggle() {
        for cell in self.collectionView.visibleCells() {
            cell.layer.removeAllAnimations()
        }
        _isWiggling = false
    }
    
    private func addWiggleAnimationToCell(cell: UICollectionViewCell) {
        CATransaction.begin()
        CATransaction.setDisableActions(false)
        cell.layer.addAnimation(rotationAnimation(), forKey: "rotation")
        cell.layer.addAnimation(bounceAnimation(), forKey: "bounce")
        CATransaction.commit()
    }
    private func rotationAnimation() -> CAKeyframeAnimation {
        let animation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        let angle = CGFloat(0.04)
        let duration = NSTimeInterval(0.1)
        let variance = Double(0.025)
        animation.values = [angle, -angle]
        animation.autoreverses = true
        animation.duration = self.randomizeInterval(duration, withVariance: variance)
        animation.repeatCount = Float.infinity
        return animation
    }
    
    private func bounceAnimation() -> CAKeyframeAnimation {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.y")
        let bounce = CGFloat(3.0)
        let duration = NSTimeInterval(0.12)
        let variance = Double(0.025)
        animation.values = [bounce, -bounce]
        animation.autoreverses = true
        animation.duration = self.randomizeInterval(duration, withVariance: variance)
        animation.repeatCount = Float.infinity
        return animation
    }
    private func randomizeInterval(interval: NSTimeInterval, withVariance variance:Double) -> NSTimeInterval {
        let random = (Double(arc4random_uniform(1000)) - 500.0) / 500.0
        return interval + variance * random;
    }
    
    // Dim screen and highlighting an item (cell)
    private func dimViewWithItem(item: UIView) {
        
        // Setup the dimming view
        let dimView = UIView()
        dimView.bounds.size = self.view.frame.size
        dimView.center = self.view.center
        dimView.tag = TAG_DIM

        // Setup and add arrows background to item (snapshot of cell)
        imgArrows.bounds.size = item.bounds.size
        imgArrows.tag = TAG_ARROWS
        item.addSubview(imgArrows)
        item.sendSubviewToBack(imgArrows)
        item.alpha = 0.2
        
//         Tap gesture recognizer for removing dimming cover
//        let windowTap = UITapGestureRecognizer(target: self, action : "removeDimCover")
//        dimView.addGestureRecognizer(windowTap)
        
        dimView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        
        // Animation of dimming and highlighting
        UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseInOut, animations: { () -> Void in
            item.alpha = 1.0
            dimView.addSubview(item)
            UIApplication.sharedApplication().keyWindow?.addSubview(dimView)
            dimView.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.8)
            }, completion: { _ in
        })
        
    }
    
    // Remove dimming cover
    func removeDimCover() {

        // self.StartActivity()
        
        self.collectionView.scrollEnabled = true

        // Animation of dimming and highlighting
        UIView.animateWithDuration(0.5, delay: 0.0, options: .CurveEaseInOut, animations: { () -> Void in
        UIApplication.sharedApplication().keyWindow?.getSubviewWithTag(self.TAG_DIM).alpha = 0.0
            }, completion: { _ in
           UIApplication.sharedApplication().keyWindow?.removeSubviewWithTag(self.TAG_DIM)
        })
        
//        for(var i = 0; i < self.arrayConnection.count; i++)
//        {
//            self.arrayConnection[i].selected = false
//            self.arrayConnection[i].hightlight = false
//        }
        
    }
    
}
extension ConnectionCollectionViewController : UICollectionViewDelegate {
    
    //
    //    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    //        print("You selected cell #\(indexPath.row)!")
    //        let defaults = NSUserDefaults.standardUserDefaults()
    //        let Userkey = defaults.stringForKey("guid")
    //
    //        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("vcChatViewController") as? ChatViewController
    //        if self.arrayConnection[indexPath.row].type == "user"
    //        {
    //            vc!.passedChatId = self.arrayConnection[indexPath.row].id + Userkey!
    //            vc!.passedFreindId = self.arrayConnection[indexPath.row].id
    //
    //        }else{//group
    //            vc!.passedChatId = self.arrayConnection[indexPath.row].id
    //
    //        }
    //        vc!.passedType = self.arrayConnection[indexPath.row].type
    //        self.navigationController?.pushViewController(vc!, animated: true)
    //
    //
    //    }
    
//TODO: Set cell size proportionally to view?
    
//    func collectionView(collectionView: UICollectionView,
//        layout collectionViewLayout: UICollectionViewLayout,
//        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
//        
//        let viewWidth = UIScreen.mainScreen().bounds.size.width
//        let collectionViewWidth = collectionView.bounds.size.width
//            
//        let cellSize = CGSize(width: viewWidth / 4, height: viewWidth / 4)
//            
//        return cellSize
//            
//    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
//         Show header shadow when scrolling begins
        self.navigationController?.navigationBar.layer.shadowOpacity = 1.0
        
        // Animate the shadow opacity to "fade it in"
//        let shadowAnim = CABasicAnimation()
//        shadowAnim.keyPath = "shadowOpacity"
//        shadowAnim.fromValue = NSNumber(float: 0.0)
//        shadowAnim.toValue = NSNumber(float: 1.0)
//        shadowAnim.duration = 1.0
        
//        self.navigationController?.navigationBar.layer.addAnimation(shadowAnim, forKey: "shadowOpacity")
//        self.navigationController?.navigationBar.layer.shadowOpacity = 1.0

    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if scrollView.isAtTop() {
            self.navigationController?.navigationBar.layer.shadowOpacity = 0.0
        }
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        // Hide header shadow when collection is on top
        if scrollView.isAtTop() {
        self.navigationController?.navigationBar.layer.shadowOpacity = 0.0
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if collectionView.isEqual(self.collectionView) {
            print("You selected cell #\(indexPath.row)!")
            self.StartActivity()

            guard let cell = collectionView.cellForItemAtIndexPath(indexPath) as? UserCell else {print("error")
                return
            }
            if self.addToGroup{
                    if self.arrayConnection[indexPath.row].type == "user" {
                        if (arrayAddUsers.indexOf({$0.id == self.arrayConnection[indexPath.row].id}) == nil) {
                            arrayAddUsers.append(self.arrayConnection[indexPath.row])
                                let containerIndexPath = [NSIndexPath(forItem: arrayAddUsers.count-1, inSection: 0)]
                                addUsersCollection.insertItemsAtIndexPaths(containerIndexPath)

                        }
                    }
                    print(arrayAddUsers)
            }
            if cell.tag == 1{
                self.showInvationPopUpView("invite", message: "bla",imagePhoto: self.arrayConnection[indexPath.row].imageData == nil ? NSData() : self.arrayConnection[indexPath.row].imageData, index: indexPath.row)

            }
            // self.collectionView.scrollEnabled = false
            self.isActive = true
            for(var i = 0; i < self.arrayConnection.count; i++)
            {
                self.arrayConnection[i].selected = false
                self.arrayConnection[i].hightlight = false
            }
            
            self.arrayConnection[indexPath.row].selected = true
            self.arrayConnection[indexPath.row].hightlight = true

             self.StopActivity()
            
        } else {
//            guard let cellAdd = collectionView.cellForItemAtIndexPath(indexPath) as? AddToGroupCell else {print("error")
//                return
//            }

            print("You selected cell #\(indexPath.item)!")
            self.arrayAddUsers.removeAtIndex(indexPath.item)
            let containerIndexPath = [NSIndexPath(forItem: indexPath.item, inSection: 0)]
            self.addUsersCollection.deleteItemsAtIndexPaths(containerIndexPath)
            // self.addUsersCollection.reloadData()
        }
        
    }
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
//        self.StartActivity()
//
//        print("You deselected cell #\(indexPath.row)!")
//     //   let cell = collectionView.cellForItemAtIndexPath(indexPath)
//        
//        guard let cell = collectionView.cellForItemAtIndexPath(indexPath) as? UserCell else {print("error")
//            return
//        }
//
//        self.isActive = false
//        self.collectionView.scrollEnabled = true
//        
//        self.arrayConnection[indexPath.row].selected = false
//        self.arrayConnection[indexPath.row].hightlight = false

        // animatedCollection(true)
    }
    func handleTap(recognizer: UITapGestureRecognizer) {
        // Handle the tap gesture
        print("tap")
        
        self.StartActivity()

        self.collectionView.scrollEnabled = true
        
        self.isActive = false
        
        for(var i = 0; i < self.arrayConnection.count; i++)
        {
            self.arrayConnection[i].selected = false
            self.arrayConnection[i].hightlight = false
        }
        
        let cells = self.collectionView.visibleCells()

        for c in cells {
            let cell = c as! UserCell
            cell.name.alpha = 1
            cell.removeSubviewWithTag(TAG_ARROWS)
        }
        
        self.StopActivity()
        
        //animatedCollection(false)
        
    }

 
    func setRoundedBorder(radius : CGFloat, withBorderWidth borderWidth: CGFloat, withColor color : UIColor, forButton button : UIButton)
    {
        let l : CALayer = button.layer
        l.masksToBounds = true
        l.cornerRadius = radius
        l.borderWidth = borderWidth
        l.borderColor = color.CGColor
    }
   // var popViewController : PopUpViewControllerSwift!

    func showInvationPopUpView(title: String, message: String, imagePhoto: NSData, index: Int) {
        
        print(self.arrayConnection[index].name)
        print(self.arrayConnection[index].phone)

        

        
        let bundle = NSBundle(forClass: PopUpInvateViewController.self)
        if (UIDevice.currentDevice().userInterfaceIdiom == .Pad)
        {
            self.popViewController = PopUpInvateViewController(nibName: "PopUpInvateViewController", bundle: bundle)
            self.popViewController.title = self.arrayConnection[index].phone
            if imagePhoto.length > 0{
                self.popViewController.showInView(self.mainView, withImage: UIImage(data: imagePhoto), withMessage: self.arrayConnection[index].name, animated: true, withNumber: self.arrayConnection[index].phone)

            }else{
                self.popViewController.showInView(self.mainView, withImage: UIImage(named: "wevo_chat_user_non"), withMessage: self.arrayConnection[index].name, animated: true, withNumber: self.arrayConnection[index].phone)

            }



        } else
        {
            if UIScreen.mainScreen().bounds.size.width > 320 {
                if UIScreen.mainScreen().scale == 3 {
                    self.popViewController = PopUpInvateViewController(nibName: "PopUpInvateViewController", bundle: bundle)
                    self.popViewController.title = self.arrayConnection[index].phone
                    if imagePhoto.length > 0{
                        self.popViewController.showInView(self.mainView, withImage: UIImage(data: imagePhoto), withMessage: self.arrayConnection[index].name, animated: true, withNumber: self.arrayConnection[index].phone)
                        
                    }else{
                        self.popViewController.showInView(self.mainView, withImage: UIImage(named: "wevo_chat_user_non"), withMessage: self.arrayConnection[index].name, animated: true, withNumber: self.arrayConnection[index].phone)
                        
                    }
                } else {
                    self.popViewController = PopUpInvateViewController(nibName: "PopUpInvateViewController", bundle: bundle)
                    self.popViewController.title = self.arrayConnection[index].phone
                    if imagePhoto.length > 0{
                        self.popViewController.showInView(self.mainView, withImage: UIImage(data: imagePhoto), withMessage: self.arrayConnection[index].name, animated: true, withNumber: self.arrayConnection[index].phone)
                        
                    }else{
                        self.popViewController.showInView(self.mainView, withImage: UIImage(named: "wevo_chat_user_non"), withMessage: self.arrayConnection[index].name, animated: true, withNumber: self.arrayConnection[index].phone)
                        
                    }
                }
            } else {
                self.popViewController = PopUpInvateViewController(nibName: "PopUpInvateViewController", bundle: bundle)
                self.popViewController.title = self.arrayConnection[index].phone
                if imagePhoto.length > 0{
                    self.popViewController.showInView(self.mainView, withImage: UIImage(data: imagePhoto), withMessage: self.arrayConnection[index].name, animated: true, withNumber: self.arrayConnection[index].phone)
                    
                }else{
                    self.popViewController.showInView(self.mainView, withImage: UIImage(named: "wevo_chat_user_non"), withMessage: self.arrayConnection[index].name, animated: true, withNumber: self.arrayConnection[index].phone)
                    
                }
            }
        }

    }
    // Hide add users container
    @IBAction func actionCloseContainer(sender: AnyObject) {
        addToGroup = false
        UIView.animateWithDuration(1.0, delay: 0.0, options: .CurveEaseInOut, animations: { () -> Void in
            self.viewAddUsers.center.y += self.viewAddUsers.bounds.height
            }, completion: { (Bool) -> Void in
                // self.viewAddUsers.hidden = true
                self.arrayAddUsers.removeAll()
                self.addUsersCollection.reloadData()
        })
    }
        // Show add users container
        func openContainer() {
            viewAddUsers.hidden = false
            
            UIView.animateWithDuration(1.0, delay: 0.0, options: .CurveEaseInOut, animations: { () -> Void in
                self.viewAddUsers.center.y -= self.viewAddUsers.bounds.height
                }, completion: { (Bool) -> Void in
            })
        }
    
}
