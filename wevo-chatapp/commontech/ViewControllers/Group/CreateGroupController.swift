//
//  CreateGroupController.swift
//  commontech
//
//  Created by matata on 09/11/2015.
//  Copyright © 2015 matata. All rights reserved.
//

import UIKit
import Alamofire
class CreateGroupController: UIViewController,UINavigationControllerDelegate, UIImagePickerControllerDelegate ,UITextFieldDelegate{
    @IBOutlet weak var activity: UIActivityIndicatorView!
    var imagePicker = UIImagePickerController()
    var isPrivate = false
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
    var passedGroupId: String!

    @IBAction func btnCancel(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)


    }
    @IBOutlet weak var txtGroupName: UITextField!
    @IBOutlet weak var groupImage: UIImageView!
    @IBOutlet weak var btnIsPrivate: UIButton!
    
    @IBOutlet weak var saveGroup: UIButton!
    
    @IBAction func changeGroupPrivateStatus(sender: AnyObject) {
        if self.isPrivate{
            self.isPrivate = false
            self.btnIsPrivate.setTitle("Make Public", forState: .Normal)
        }else{
            self.isPrivate = true
            self.btnIsPrivate.setTitle("Make Private", forState: .Normal)

        }
    }
    @IBAction func editGroupImage(sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum){
            print("Button capture")
            
            
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum;
            imagePicker.allowsEditing = false
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!){
        self.dismissViewControllerAnimated(true, completion: { () -> Void in
            
        })
        groupImage.image = resizeImage(image!, newWidth: 200)

      //  groupImage.image = image


    }
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight))
        image.drawInRect(CGRectMake(0, 0, newWidth, newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    @IBAction func saveGroupName(sender: AnyObject) {
        self.StartActivity()
        saveGroup.hidden = true
        self.view.endEditing(true)
        txtGroupName.userInteractionEnabled = false

        let groupName = txtGroupName.text
        //retrive uinque id from defualt 
        let defaults = NSUserDefaults.standardUserDefaults()
        
        let UserId = defaults.stringForKey("guid")
        if(passedGroupId == nil){
            //in server need to be class Groups
//            var parametersToSend = [
//                "OwnerUserId": (UserId as? AnyObject)!,
//                "GroupId": "nb",
//                "GroupName": (groupName as? AnyObject)!
//            ]
            // init paramters Dictionary
//            let parametersToSend = [
//                "OwnerUserId": UserId!,
//                "GroupId": "",
//                "GroupName": groupName!
//              //  "GroupPrivate": self.isPrivate
//            ]
            let postEndpoint = "http://wevoapi.azurewebsites.net:80/api/groups"
            let headers = ["Authorization": defaults.stringForKey("guid")!]

            
            // example image data
           // let image = UIImage(named: "IMG_0801.PNG")
           // let imageData = UIImagePNGRepresentation(image!)
            let imageData = UIImagePNGRepresentation(groupImage.image!)

            // CREATE AND SEND REQUEST ----------
           // let urlRequest = urlRequestWithComponents("http://wevoapi.azurewebsites.net:80/api/files", parameters: parametersToSend, imageData: imageData!)

            let urlRequest = urlRequestWithComponents("http://wevoapi.azurewebsites.net:80/api/files", imageData: imageData!)
            
            Alamofire.upload(urlRequest.0, data: urlRequest.1)
                .progress { (bytesWritten, totalBytesWritten, totalBytesExpectedToWrite) in
                    print("\(totalBytesWritten) / \(totalBytesExpectedToWrite)")
                }
                .responseJSON { response in
                    print("RESPONSE \(response)")
                    let resultArr : NSArray = (response.result.value as? NSArray)!
                    for item in resultArr {
                        //let resultDic : NSDictionary =  (response.result.value as? NSDictionary)!
                        if item.valueForKey("Location") === NSNull(){
                            let alert = UIAlertController(title: "Error", message: "Error in save image", preferredStyle: UIAlertControllerStyle.Alert)
                            alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
                            
                            self.presentViewController(alert, animated: true, completion: nil)
                        }else{
                            let parametersToSend = [
                                "OwnerUserId": (UserId! as? AnyObject)!,
                                "GroupId": "",
                                "GroupName": (groupName! as? AnyObject)!,
                                "GroupPrivate": (self.isPrivate == true ? "true" : "false"),
                                "GroupImageUrl": (item.valueForKey("Location"))!
                            ]
                            Alamofire.request(.POST, postEndpoint, parameters:  parametersToSend, headers: headers).responseJSON { response in
                                print(response)
                                self.StopActivity()
                                
                                //if let navController = self.navigationController {
                                //  navController.popViewControllerAnimated(true)
                                //}
                                let vc = self.storyboard?.instantiateViewControllerWithIdentifier("vcChooseUsersForGroup") as? ChooseUsersViewController
                                vc!.passedValue = "nb"//self.arrayGroup[indexPath!.row].GroupId
                                vc!.isViewMembersGroup = false
                                
                                self.navigationController?.pushViewController(vc!, animated: true)
                            }
                        }
                    }
            }


        }
        else{
            //in server need to be class Groups
            let parametersToSend = [
                "stringValue": (groupName as? AnyObject)!
            ]
            let postEndpoint = "http://wevoapi.azurewebsites.net:80/api/groups/" + passedGroupId
            let headers = ["Authorization": defaults.stringForKey("guid")!]
            Alamofire.request(.PUT, postEndpoint, parameters:  parametersToSend, headers: headers).responseJSON { response in

                print(response)
                self.StopActivity()
                if let navController = self.navigationController {
                    navController.popViewControllerAnimated(true)
                }
            }
        }

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        activity.hidden = true
        saveGroup.layer.cornerRadius = 10;
        saveGroup.layer.borderWidth = 1;
        saveGroup.layer.borderColor = UIColor.darkGrayColor().CGColor
        
        txtGroupName.addTarget(self, action: "textFieldDidChange:", forControlEvents: UIControlEvents.EditingChanged)
        saveGroup.enabled = false
        self.txtGroupName.delegate = self;

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    func textFieldDidChange(textField: UITextField) {
        let swiftColor = UIColor(red: 0.388, green: 0.11, blue: 0.12, alpha: 1)
        if textField.text!.characters.count > 3{
            saveGroup.layer.backgroundColor = swiftColor.CGColor
            saveGroup.enabled = true
            saveGroup.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)

        }else{
            saveGroup.layer.backgroundColor = UIColor.whiteColor().CGColor
            saveGroup.enabled = false
            saveGroup.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)

        }

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    // this function creates the required URLRequestConvertible and NSData we need to use Alamofire.upload
    //func urlRequestWithComponents(urlString:String, parameters:Dictionary<String, String>, imageData:NSData) -> (URLRequestConvertible, NSData)
    func urlRequestWithComponents(urlString:String, imageData:NSData) -> (URLRequestConvertible, NSData)
    {
        let uuid = NSUUID().UUIDString

        // create url request to send
        let mutableURLRequest = NSMutableURLRequest(URL: NSURL(string: urlString)!)
        mutableURLRequest.HTTPMethod = Alamofire.Method.POST.rawValue
        let boundaryConstant = "myRandomBoundary12345";
        let contentType = "multipart/form-data;boundary="+boundaryConstant
        mutableURLRequest.setValue(contentType, forHTTPHeaderField: "Content-Type")
    
        // create upload data to send
        let uploadData = NSMutableData()
        
        // add image
        uploadData.appendData("\r\n--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData("Content-Disposition: form-data; name=\"file\"; filename=\"\(uuid).png\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData("Content-Type: image/png\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        uploadData.appendData(imageData)
        
        // add parameters
//        for (key, value) in parameters {
//            uploadData.appendData("\r\n--\(boundaryConstant)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
//            uploadData.appendData("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n\(value)".dataUsingEncoding(NSUTF8StringEncoding)!)
//        }
        uploadData.appendData("\r\n--\(boundaryConstant)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)

        // return URLRequestConvertible and NSData
        return (Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: nil).0, uploadData)
    }
}
