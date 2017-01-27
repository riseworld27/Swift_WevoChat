//
//  AppDelegate.swift
//  commontech
//
//  Created by matata on 07/10/2015.
//  Copyright © 2015 matata. All rights reserved.
//

import UIKit
import CoreData
import FBSDKCoreKit
import ParseFacebookUtilsV4
import OAuthSwift
import Contacts
import Alamofire

import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate {

    var window: UIWindow?
    var store = CNContactStore()
    let myDevice = UIDevice.currentDevice().identifierForVendor

  
    func applicationWillResignActive(application: UIApplication) {
    }

  
    func applicationWillEnterForeground(application: UIApplication) {
    }
    
//MARK:facebook login
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        
            if (url.host == "oauth-callback") {
                if (url.path!.hasPrefix("/twitter") || url.path!.hasPrefix("/flickr") || url.path!.hasPrefix("/fitbit")
                    || url.path!.hasPrefix("/withings") || url.path!.hasPrefix("/linkedin") || url.path!.hasPrefix("/bitbucket") || url.path!.hasPrefix("/smugmug") || url.path!.hasPrefix("/intuit") || url.path!.hasPrefix("/zaim") || url.path!.hasPrefix("/tumblr")) {
                        OAuth1Swift.handleOpenURL(url)
                        return true
                        
                }
                if ( url.path!.hasPrefix("/github" ) || url.path!.hasPrefix("/instagram" ) || url.path!.hasPrefix("/foursquare") || url.path!.hasPrefix("/dropbox") || url.path!.hasPrefix("/dribbble") || url.path!.hasPrefix("/salesforce") || url.path!.hasPrefix("/google") || url.path!.hasPrefix("/linkedin2") || url.path!.hasPrefix("/slack") || url.path!.hasPrefix("/uber")) {
                    OAuth2Swift.handleOpenURL(url)
                    return true
                }
            }
        let urlstring = url.absoluteString

        if urlstring.rangeOfString("fb134294503608991") != nil{
            return FBSDKApplicationDelegate.sharedInstance().application(application,
                openURL: url,
                sourceApplication: sourceApplication,
                annotation: annotation)
        }
        
        if (url.host == "authorize"){
            OAuth2Swift.handleOpenURL(url)
            return true
            
        }else {
//            let notification = NSNotification(
//                name: "AGAppLaunchedWithURLNotification",
//                object:nil,
//                userInfo:[UIApplicationLaunchOptionsURLKey:url])
//            NSNotificationCenter.defaultCenter().postNotification(notification)
//            let code = self.extractCode(notification)
//            print(code)
            OAuth1Swift.handleOpenURL(url)

        }

        return true
    }
    
    func registerNotification(){
        
        /*
        if UIApplication.sharedApplication().respondsToSelector("registerUserNotificationSettings:") {
            // It's iOS 8
            var types = UIUserNotificationType.Badge | UIUserNotificationType.Sound | UIUserNotificationType.Alert
            var settings = UIUserNotificationSettings(forTypes: types, categories: nil)
            UIApplication.sharedApplication().registerUserNotificationSettings(settings)
        } else {
            // It's older
            var types = UIRemoteNotificationType.Badge | UIRemoteNotificationType.Sound | UIRemoteNotificationType.Alert
            UIApplication.sharedApplication().registerForRemoteNotificationTypes(types)
        }*/
        
        
        let application = UIApplication.sharedApplication()
        
        if application.respondsToSelector("isRegisteredForRemoteNotifications")
        {
            // iOS 8 Notifications
            application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Badge , .Sound , .Alert], categories: nil));
            application.registerForRemoteNotifications()
        }
        else
        {
            // iOS < 8 Notifications
            application.registerForRemoteNotificationTypes([.Badge , .Sound , .Alert])

        }

    }
    
    func extractCode(notification: NSNotification) -> String? {
        
        let url: NSURL? = (notification.userInfo as!
            [String: AnyObject])[UIApplicationLaunchOptionsURLKey] as? NSURL
        
        // [1] extract the code from the URL
        return self.parametersFromQueryString(url?.query)["code"]
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
    
    class func getAppDelegate() -> AppDelegate {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }
    
    //Make sure it isn't already declared in the app delegate (possible redefinition of func error)
    func applicationDidBecomeActive(application: UIApplication) {
        FBSDKAppEvents.activateApp()
        self.doBackgroundTask()

    }

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        
        let tokenString : NSMutableString = NSMutableString.init(string: deviceToken.description.uppercaseString)
        
        print(tokenString)
        
        tokenString.replaceOccurrencesOfString("<", withString: "", options: NSStringCompareOptions.RegularExpressionSearch, range: NSRange(location: 0, length: tokenString.length))
        
        tokenString.replaceOccurrencesOfString(">", withString: "", options: NSStringCompareOptions.RegularExpressionSearch, range: NSRange(location: 0, length: tokenString.length))

        tokenString.replaceOccurrencesOfString(" ", withString: "", options: NSStringCompareOptions.RegularExpressionSearch, range: NSRange(location: 0, length: tokenString.length))
        
        gTokenString = tokenString as String

        
        //NSMutableString *tokenString = [NSMutableString stringWithString:[[deviceToken description] uppercaseString]];
    }
    func applicationWillTerminate(application: UIApplication) {
        self.saveContext()
    }


    lazy var applicationDocumentsDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource("evocommontech", withExtension: "momd")!

       // let modelURL = NSBundle.mainBundle().URLForResource("wevo-commontech", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()


    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }

    func checkAccessStatus(completionHandler: (accessGranted: Bool) -> Void) {
        let authorizationStatus = CNContactStore.authorizationStatusForEntityType(CNEntityType.Contacts)
        
        switch authorizationStatus {
        case .Authorized:
            completionHandler(accessGranted: true)
        case .Denied, .NotDetermined:
            self.store.requestAccessForEntityType(CNEntityType.Contacts, completionHandler: { (access, accessError) -> Void in
                if access {
                    completionHandler(accessGranted: access)
                }
                else {
                    print("access denied")
                }
            })
        default:
            completionHandler(accessGranted: false)
        }
    }
    class func sharedDelegate() -> AppDelegate {
        return UIApplication.sharedApplication().delegate as! AppDelegate
    }
    func checkIdentifierForVendor() -> String
    {
         return myDevice!.UUIDString

    }

    //MARK: location operations
    //location properties
    let locationManager = CLLocationManager()
    var pos = 0
    var LatitudeGPS = NSString()
    var LongitudeGPS = NSString()
    var speedGPS = NSString()
    var Course = NSString()
    var Altitude = NSString()
    var bgtimer = NSTimer()
    
    var backgroundUpdateTask: UIBackgroundTaskIdentifier!
    
    func beginBackgroundUpdateTask() {
        self.backgroundUpdateTask = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({
            self.endBackgroundUpdateTask()
        })
    }
    func endBackgroundUpdateTask() {
        UIApplication.sharedApplication().endBackgroundTask(self.backgroundUpdateTask)
        self.backgroundUpdateTask = UIBackgroundTaskInvalid
    }
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Parse.setApplicationId("kqrdXkRHa0GagOKTzp9vwnETsc2Q102Pf6L63lfE", clientKey:"LvD4t0WgW6Fz04eykqzxLBaBChxFk6XyCa0Fzkl9")
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
        
        let navBGImage: UIImage! = UIImage(named: "wevo_navbar_bg")
        UINavigationBar.appearance().setBackgroundImage(navBGImage, forBarMetrics: .Default)
        UINavigationBar.appearance().shadowImage = UIImage()

        self.registerNotification()
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
    }

    func doBackgroundTask() {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            self.beginBackgroundUpdateTask()
            
            // Do something
            self.StartupdateLocation()
            
            self.bgtimer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: "bgtimer:", userInfo: nil, repeats: true)
            NSRunLoop.currentRunLoop().addTimer(self.bgtimer, forMode: NSDefaultRunLoopMode)
            NSRunLoop.currentRunLoop().run()
            
            
            // End the background task.
            self.endBackgroundUpdateTask()
        })
    }
    func bgtimer(timer:NSTimer!){
        
       // print("Fired from Background ************************************")
        
        updateLocation()
        
     //   print("Position Report: \(pos)")
        
    }
    func StartupdateLocation() {
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.requestWhenInUseAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
    }
    func updateLocation() {
        pos++
        
        //locationManager.startUpdatingLocation()
        //locationManager.stopUpdatingLocation()
        
//        print("Latitude: \(LatitudeGPS)")
//        print("Longitude: \(LongitudeGPS)")
//        print("Speed: \(speedGPS)")
//        print("Heading: \(Course)")
//        print("Altitude BG: \(Altitude)")
//        print(UIApplication.sharedApplication().backgroundTimeRemaining)
    //    let defaults = NSUserDefaults.standardUserDefaults()
     //   let UserId = defaults.stringForKey("UserId")
     //   var headers = ["Authorization": ""]
     //   if(defaults.stringForKey("UserId") != nil){
     //       headers = ["Authorization": defaults.stringForKey("UserId")!]
    //    }
//        let parametersToSend = [
//            "userId":(UserId as? AnyObject)!,
//            "Latitude": LatitudeGPS,
//            "Longitude": LongitudeGPS,
//            "Speed": speedGPS,
//            "Heading": Course,
//            "Altitude": Altitude
//        ]
//        let postEndpoint = "http://wevoapi.azurewebsites.net:80/api/Location/SaveLocation"
//        Alamofire.request(.POST, postEndpoint, parameters: parametersToSend, headers: headers).responseJSON { response in
//            print(response)
//        }
    }
    func applicationDidEnterBackground(application: UIApplication) {
        //self.doBackgroundTask()
        self.updateTimer(self.bgtimer)
    }
    func updateTimer( timer: NSTimer) {
        timer.invalidate()
        print("killed location when go to background")

    }
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        
        LatitudeGPS = String(format: "%.10f", manager.location!.coordinate.latitude)
        LongitudeGPS = String(format: "%.10f", manager.location!.coordinate.longitude)
        speedGPS = String(format: "%.3f", manager.location!.speed)
        Altitude = String(format: "%.3f", manager.location!.altitude)
        Course = String(format: "%.3f", manager.location!.course)
        
    }

}
extension String {
    public func urlEncode() -> String {
        let encodedURL = CFURLCreateStringByAddingPercentEscapes(
            nil,
            self as NSString,
            nil,
            "!@#$%&*'();:=+,/?[]",
            CFStringBuiltInEncodings.UTF8.rawValue)
        return encodedURL as String
    }
}
