//
//  ChatViewController.swift
//  commontech
//
//  Created by matata on 12/17/15.
//  Copyright © 2015 matata. All rights reserved.
//

import UIKit
import PubNub
import JSQMessagesViewController
import MobileCoreServices
import Foundation
import MediaPlayer
import AVFoundation
import AVKit
import Alamofire
import GPUImage
import OAuthSwift
import CoreData


class ChatViewController: JSQMessagesViewController {
    //TODO: 1: build get my user info class User
    ///api/users/{userid}/chat 
    //2:below is the parameters of the other user that i click on passed with the view controller
    var otherUserId: String!
    var otherUserName: String!
    var otherUserImage: String!
    var otherUserPhone: String!
    
    var messageOriginNum = 0
    var flgChanged = 0;
    var indexMessage = 0
    
    var myUser: Users!
    var otherUser: Users!
    var groupUsers: [Users] = []
    var passedType: String!//user/group
    
    //TODO: chat id
    //user1 <=> user2 chat id => userGuid1 + userGuid2
    //user <=> group chat id => groupGuid
    var passedChatId: String!//chat Id
    var passedFreindId: String!//only between 2 users
    
    override class func nib() -> UINib {
        return UINib(nibName: "ChatViewController", bundle: nil)
    }

    func showAlertView(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    func getUserChat(){
        let defaults = NSUserDefaults.standardUserDefaults()

        let headers = ["Authorization": defaults.stringForKey("guid")!]
        
        Alamofire.request(.GET, "http://wevoapi.azurewebsites.net:80/api/users/"+defaults.stringForKey("guid")!+"/chat" , parameters:  nil, headers: headers).responseJSON { response in
            print(response)
            if(response.result.value === NSNull() || response.result.value === nil){
                self.showAlertView("Error", message: "NULL object")
                
            }else{
                let resultDic : NSDictionary =  (response.result.value as? NSDictionary)!
                if resultDic.valueForKey("data")! === NSNull(){
                    self.showAlertView("Error", message: "NULL object")
                    
                    return
                }
                self.myUser =  Users(userId: (resultDic.valueForKey("data")!.valueForKey("userId") as? String)!, userName: (resultDic.valueForKey("data")!.valueForKey("userName") as? String)!, userImage: (resultDic.valueForKey("data")!.valueForKey("userImage") as? String)!, userPhone: (resultDic.valueForKey("data")!.valueForKey("userPhone") as? String)!)!
            }

        }
    }
    
    func getFriendUserChat(){
        let defaults = NSUserDefaults.standardUserDefaults()
        
        let headers = ["Authorization": defaults.stringForKey("guid")!]
        
        Alamofire.request(.GET, "http://wevoapi.azurewebsites.net:80/api/users/"+self.passedFreindId!+"/chat" , parameters:  nil, headers: headers).responseJSON { response in
            print(response)
            if(response.result.value === NSNull() || response.result.value === nil){
                self.showAlertView("Error", message: "NULL object")
                
            }else{
                let resultDic : NSDictionary =  (response.result.value as? NSDictionary)!
                if resultDic.valueForKey("data")! === NSNull(){
                    self.showAlertView("Error", message: "NULL object")

                    return
                }
                self.otherUser =  Users(userId: (resultDic.valueForKey("data")!.valueForKey("userId") as? String)!, userName: (resultDic.valueForKey("data")!.valueForKey("userName") as? String)!, userImage: (resultDic.valueForKey("data")!.valueForKey("userImage") as? String)!, userPhone: (resultDic.valueForKey("data")!.valueForKey("userPhone") as? String)!)!
                self.otherUserName = self.otherUser.userName
            }
            
            if self.passedType == "user"{
                self.showHeaderView()
            }
        }
    }
    
    func getGroupChat(){
        let defaults = NSUserDefaults.standardUserDefaults()

        let headers = ["Authorization": defaults.stringForKey("guid")!]
        
        Alamofire.request(.GET, "http://wevoapi.azurewebsites.net:80/api/groups/"+self.passedChatId!+"/chat" , parameters:  nil, headers: headers).responseJSON { response in
            print(response)
            let resultDic : NSDictionary =  (response.result.value as? NSDictionary)!
            if resultDic.valueForKey("data")! === NSNull(){
                self.showAlertView("Error", message: "NULL object")
                
                return
            }
            let resultArr : NSArray =  (resultDic.valueForKey("data") as? NSArray)!
            for item in resultArr{
                let user = Users(userId: (item.valueForKey("userId") as? String)!, userName: (item.valueForKey("userName") as? String)!, userImage: (item.valueForKey("userImage") as? String)!, userPhone: (item.valueForKey("userPhone") as? String)!)!
                self.groupUsers.append(user)
            }
            

        }
    }
    
    //TODO: get 3 parameters from previews view of user you chat with
    
    @IBOutlet weak var navItem: WevoNavigationBar!
    @IBOutlet weak var taBar: UITabBar!
    
    var imageView:UIImageView = UIImageView.init(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height))
    
    var recordView: UIView!
    var videoView: UIView!
    var videoRecordView: UIView!
    
    var videoBackgroundView: UIView!
    var videoCaptureView: UIView!
    
    var headerView: UIView = UIView.init(frame: CGRectMake(0, 90, UIScreen.mainScreen().bounds.width, 60))
    
    var btn1, btn2, btn3, btn4: UIButton!
    
    var textDuration: UILabel!
    
    var recVideoStatusBtn : UIButton!
    var lblVideoStatus : UILabel!
    var lblVideoDuration : UILabel!
    
    var moviePlayer : AVPlayerViewController!
    
    var mVideoCamera : GPUImageVideoCamera!
    var mMovieWriter : GPUImageMovieWriter!
    var mCropFilter : GPUImageFilter!
    var mFilterView : GPUImageView!
    
    var mTorchModeVideo : AVCaptureTorchMode!
    
    var kTempMoviePath : String!
    var kCapturedMoviePath : String!
    
    var config : PNConfiguration = PNConfiguration(publishKey: PubNubKeys.PublishKey, subscribeKey: PubNubKeys.SubscribeKey)
    var client : PubNub?
    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1.0))
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor(red: 252/255, green: 246/255, blue: 164/255, alpha: 1.0))
    let dateBubble = JSQMessagesBubbleImageFactory.init(bubbleImage: UIImage.init(named: Images.ChatOptions), capInsets: UIEdgeInsetsZero)

    var messages = [MessageData]()
    var audioPlayer: AVAudioPlayer!
    var audioRecorder: AVAudioRecorder!
    var recordingSession: AVAudioSession!
    
    var mDuringTimer : NSTimer?
    var mDuringVideoTimer : NSTimer?
    
    var mCounterDuringTimer : Int64 = 0
    var mCounterDuringVideoTimer : Int64 = 0
    var mVideoRecStatus : Bool = false
    
    var mCameraMode : Int64 = 1     // 1: Video Mode   2: Photo Mode
    
    var constraintNextBottom: CGFloat! = 0
    
    //Lifecycle methods
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        dateMessage = ""
        
        if passedType == nil{
            return;
        }
        else if passedType == "user"{
            getUserChat()
            getFriendUserChat()
        }
        else if passedType == "group"{
            getUserChat()
            getGroupChat()
        }
        
        self.showHeaderTabView()
        
        self.showLoadEarlierMessagesHeader = true
        self.viewSetup()

        self.setup()
        self.initNavBar()
        
        self.initializeRecorder()
        self.getUserChat()
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "onFinishRecordVideo",
            name: "NOTIF_DID_FINISH_RECORD_VIDEO",
            object: nil)
        
        mTorchModeVideo == AVCaptureTorchMode.Off
    }
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "keyboardWillShow:",
            name: UIKeyboardWillShowNotification,
            object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "keyboardWillHide:",
            name: UIKeyboardWillHideNotification,
            object: nil)
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillAppear(animated)
        
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: UIKeyboardWillShowNotification,
            object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: UIKeyboardWillHideNotification,
            object: nil)
    }
    
    override func viewDidLayoutSubviews() {
//        self.imageView.translatesAutoresizingMaskIntoConstraints = false
//        
//        let horizontalConstraint = NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[v1]-0-|", options: .AlignAllCenterX, metrics: nil, views: ["v1": self.imageView])
//        
//        // self.view.addSubview(self.imageView)
//        
//        self.view.addConstraints(horizontalConstraint)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Keyboard
    func keyboardWillShow(notification: NSNotification) {
        let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        let duration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let animationOption = (notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).unsignedIntegerValue
        
        UIView.animateWithDuration(duration,
            delay: 0,
            options: UIViewAnimationOptions(rawValue: animationOption),
            animations: {
                self.constraintNextBottom = keyboardFrame.size.height
                self.view.layoutIfNeeded()
            }, completion: { finished in
        })
    }
    
    func keyboardWillHide(notification: NSNotification) {
        let duration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue
        let animationOption = (notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).unsignedIntegerValue
        
        UIView.animateWithDuration(duration,
            delay: 0,
            options: UIViewAnimationOptions(rawValue: animationOption),
            animations: {
                self.constraintNextBottom = 0
                self.view.layoutIfNeeded()
            }, completion: { finished in
        })
    }
    
    func viewToolBar(){
        
    }
    
    func didPressProfile(sender: UIButton!)
    {
        btn1.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        btn2.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        btn3.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        btn4.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
    }
    
    func didPressTrends(sender: UIButton!)
    {
        btn1.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        btn2.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        btn3.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        btn4.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
    }
    
    func didPressDiscover(sender: UIButton!)
    {
        btn1.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        btn2.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        btn3.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        btn4.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
    }
    
    func didPressChat(sender: UIButton!)
    {
        btn1.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        btn2.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        btn3.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        btn4.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
    }
    
    func showHeaderTabView(){
        let tabView = UIView.init(frame: CGRectMake(0, 64, UIScreen.mainScreen().bounds.width, 30))
        
        //tabView.backgroundColor = UIColor.blueColor()
        tabView.backgroundColor = (UIColor(red: 111/255, green: 111/255, blue: 111/255, alpha: 1.0))
        
        btn1 = UIButton(frame: CGRectMake(20,7, UIScreen.mainScreen().bounds.width / 4 - 20, 15))
        
        btn1.addTarget(self, action: "didPressProfile:", forControlEvents: .TouchUpInside)
        btn1.titleLabel!.font = UIFont(name: "Helvetica Neue", size: 14)
        btn1.setTitle("Profile", forState: UIControlState.Normal)
        btn1.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        
        btn2 = UIButton(frame: CGRectMake(UIScreen.mainScreen().bounds.width / 4 + 20, 7, UIScreen.mainScreen().bounds.width / 4 - 20, 15))
        
        btn2.addTarget(self, action: "didPressTrends:", forControlEvents: .TouchUpInside)
        btn2.titleLabel!.font = UIFont(name: "Helvetica Neue", size: 14)
        btn2.setTitle("Trends", forState: UIControlState.Normal)
        
        btn2.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        
        btn3 = UIButton(frame: CGRectMake(UIScreen.mainScreen().bounds.width / 2 + 20, 7, UIScreen.mainScreen().bounds.width / 4, 15))
        
        btn3.addTarget(self, action: "didPressDiscover:", forControlEvents: .TouchUpInside)
        btn3.titleLabel!.font = UIFont(name: "Helvetica Neue", size: 14)
        btn3.setTitle("Discover", forState: UIControlState.Normal)
        btn3.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        
        btn4 = UIButton(frame: CGRectMake(UIScreen.mainScreen().bounds.width / 4 * 3 + 20, 7, UIScreen.mainScreen().bounds.width / 4 - 20, 15))
        
        btn4.addTarget(self, action: "didPressChat:", forControlEvents: .TouchUpInside)
        btn4.titleLabel!.font = UIFont(name: "Helvetica Neue", size: 14)
        btn4.setTitle("Chat", forState: UIControlState.Normal)
        btn4.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        
        tabView.addSubview(btn1)
        tabView.addSubview(btn2)
        tabView.addSubview(btn3)
        tabView.addSubview(btn4)
        
        self.view.addSubview(tabView)
    }
    func showHeaderView(){
        ////////////// Header View ////////////
        //headerView = UIView.init(frame: CGRectMake(0, 90, UIScreen.mainScreen().bounds.width, 60))
        headerView.backgroundColor = (UIColor(red: 71/255, green: 71/255, blue: 72/255, alpha: 1.0))
        //headerView.backgroundColor = UIColor.redColor()
        
        let profileImageView = UIImageView.init(frame: CGRectMake(0, 0, 50, 50))
        
        let pictureURL = NSURL(string:self.otherUser.userImage)
        if let profileImageData = NSData(contentsOfURL: pictureURL!){
            
            profileImageView.image = UIImage(data: profileImageData)
        }
        else{
            profileImageView.image = UIImage(named: Images.ChatAudioPlayerProfile)
        }
        
        profileImageView.layer.cornerRadius = profileImageView.frame.size.width / 2.0
        profileImageView.clipsToBounds = true
        profileImageView.center = CGPointMake(40, 30)
        
        let label = UILabel(frame: CGRectMake(0, 0, 150, 21))
        label.center = CGPointMake(150, 33)
        label.textAlignment = NSTextAlignment.Left
        label.textColor = (UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0))
        label.text = self.otherUser.userName
        
        let imageDot = UIImage.init(named: Images.ChatOptions)
        let OptionBtn = UIButton.init(frame: CGRectMake(0, 0, 50, 50))
        
        OptionBtn.setImage(imageDot, forState: UIControlState.Normal)
        OptionBtn.center = CGPointMake(UIScreen.mainScreen().bounds.width - 30, 33)
        OptionBtn.addTarget(self, action: "didPressOption:", forControlEvents: .TouchUpInside)
        
        headerView.addSubview(profileImageView)
        headerView.addSubview(label)
        headerView.addSubview(OptionBtn)
        
        self.view.addSubview(headerView)
    }
    //Apperance
    func viewSetup() {
        
        //Chat background color
        self.collectionView?.backgroundColor = (UIColor(red: 43/255, green: 44/255, blue: 43/255, alpha: 1.0))
        
        //Hide avater for message
        // self.collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
        // self.collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
        
        //Change send button to audio button and add it's target
        //////// Audio Image /////////
        let imageAudio = UIImage.init(named: Images.ChatAudioMsg)
        let audioBtn = UIButton.init(frame: CGRectMake(0, 0, (imageAudio?.size.width)!, (imageAudio?.size.height)!))
        
        audioBtn.setImage(imageAudio, forState: UIControlState.Normal)
        //audioBtn.addTarget(self, action: "recordAudioMessage:", forControlEvents: .TouchUpInside)
        let audioBtnGesture = UILongPressGestureRecognizer(target: self, action: Selector("audioStartGesture:"))
        
        audioBtn.addGestureRecognizer(audioBtnGesture)
        
        recordView = UIView.init(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, (imageAudio?.size.height)!))
        
        //////// Video Image ///////////
        let imageVideo = UIImage.init(named: Images.ChatVideoMsg)
        let videoBtn = UIButton.init(frame: CGRectMake((imageAudio?.size.width)! + 10, 0, (imageVideo?.size.width)!, (imageVideo?.size.height)!))
        
        videoBtn.setImage(imageVideo, forState: UIControlState.Normal)
        //videoBtn.addTarget(self, action: "recordVideoMessage:", forControlEvents: .TouchUpInside)
        
        
        //let videoGesture = UISwipeGestureRecognizer(target: self, action: Selector("swipeVideoGesture:"))
        let videoBtnGesture = UILongPressGestureRecognizer(target: self, action: Selector("videoStartGesture:"))
        
        videoBtn.addGestureRecognizer(videoBtnGesture)
    
        ////////////////////////////////////////////////
        
        let rightView = UIView.init(frame: CGRectMake(0, 0, (imageVideo?.size.width)! + (imageAudio?.size.width)! + 10, (imageVideo?.size.height)!))

        rightView.addSubview(audioBtn)
        rightView.addSubview(videoBtn)
        
        ///////// Attachment icon //////////////
        let imageAttach = UIImage.init(named: Images.ChatAttachMsg)
        let attachBtn = UIButton.init(frame: CGRectMake(0, 0, (imageAttach?.size.width)!, (imageAttach?.size.height)!))
        
        attachBtn.setImage(imageAttach, forState: UIControlState.Normal)
        attachBtn.addTarget(self, action: "didPressAccessoryButton:", forControlEvents: .TouchUpInside)
        ////////////////////////////////////////////
        
        //self.inputToolbar!.contentView!
        
        self.inputToolbar!.contentView!.leftBarButtonItem = attachBtn
        //self.inputToolbar!.contentView!.leftBarButtonItem?.hidden = true
        
        self.inputToolbar!.contentView!.rightBarButtonItem = UIButton()
        self.inputToolbar!.contentView?.rightBarButtonItemWidth = (imageVideo?.size.width)! + (imageAudio?.size.width)! + 10
        
        self.inputToolbar!.contentView?.rightBarButtonContainerView?.addSubview(rightView)
        
        self.inputToolbar!.contentView!.rightBarButtonItem?.enabled = true
        
        //Change return button to send button
        self.keyboardController.textView?.returnKeyType = UIReturnKeyType.Send

        //Change keyboard input bar apperance
        self.inputToolbar?.backgroundColor = UIColor.whiteColor()
        self.inputToolbar?.contentView?.backgroundColor = UIColor.whiteColor()
        //self.inputToolbar?.contentView?.backgroundColor = UIColor.blackColor()
        self.keyboardController.textView?.layer.borderWidth = 0.0
        
        
    }
    
    
    
    override func finishSendingMessageAnimated(animated: Bool) {
        
        super.finishSendingMessageAnimated(animated)
        self.inputToolbar!.contentView!.rightBarButtonItem?.enabled = true
    }
}

extension ChatViewController : AVAudioRecorderDelegate {
    
    //Ask for permissions for the audio button
    func initializeRecorder() {
        
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            try recordingSession.overrideOutputAudioPort(AVAudioSessionPortOverride.Speaker)
            
            recordingSession.requestRecordPermission() { [unowned self] (allowed: Bool) -> Void in
                dispatch_async(dispatch_get_main_queue()) {
                    if allowed {
                        print("got permission to record")
                    } else {
                        print("didn't get permission to record")
                    }
                }
            }
        } catch {
            print("failed to get record permissions")
        }
    }
    
    //Recored Whilr the user is holding the video button
    func recordVideoMessage_TMP(sender: UIButton!){
        
        //static let ChatVideoRecordMsg = "wevo_chat_record_button"
        //static let ChatCameraVideoMsg = "wevo_chat_video_msg"
        
        //var imageView:UIImageView = UIImageView.init(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height))
        
        self.inputToolbar?.contentView!.textView!.resignFirstResponder()
        print("video message")
        
        videoView = UIView.init(frame: CGRectMake(UIScreen.mainScreen().bounds.size.width / 2 - 50, UIScreen.mainScreen().bounds.size.height / 2 - 50, 100, 100))
        videoView.backgroundColor = UIColor.clearColor()
        
        ///////// Record icon //////////////
        
        let imageVideoRecord = UIImage.init(named: Images.ChatVideoRecordMsg)
        let recordVideoBtn = UIButton.init(frame: CGRectMake(0, 50, (imageVideoRecord?.size.width)!, (imageVideoRecord?.size.height)!))
        
        recordVideoBtn.setImage(imageVideoRecord, forState: UIControlState.Normal)
        recordVideoBtn.addTarget(self, action: "didPressVideoBtn:", forControlEvents: .TouchUpInside)
        videoView.addSubview(recordVideoBtn)
        
        ///////// Camera icon ////////////////
        let imageCamera = UIImage.init(named: Images.ChatCameraVideoMsg)
        let cameraBtn = UIButton.init(frame: CGRectMake(50, 0, (imageCamera?.size.width)!, (imageCamera?.size.height)!))
        
        cameraBtn.setImage(imageCamera, forState: UIControlState.Normal)
        cameraBtn.addTarget(self, action: "didPressCameraButton:", forControlEvents: .TouchUpInside)
        videoView.addSubview(cameraBtn)
        
        ///////// Cancel icon ////////////////
        let imageCancel = UIImage.init(named: Images.ChatIconPrivet)
        let cancelBtn = UIButton.init(frame: CGRectMake(60, 60, (imageCancel?.size.width)!, (imageCancel?.size.height)!))
        
        cancelBtn.setImage(imageCancel, forState: UIControlState.Normal)
        cancelBtn.addTarget(self, action: "didPressCancelButton:", forControlEvents: .TouchUpInside)
        
        videoView.addSubview(cancelBtn)
        //recordView = UIView.init(frame: CGRectMake(0, 5, UIScreen.mainScreen().bounds.width, (imageVideoRecord?.size.height)!))
        
        //self.inputToolbar!.contentView?.addSubview(videoView)
        self.view.addSubview(videoView)
    }
    
    func startRecVideo(){
        
        self.kTempMoviePath = NSTemporaryDirectory() + "/temp.mov"
        
        do {
            try NSFileManager.defaultManager().removeItemAtPath(self.kTempMoviePath)
            
        }
        catch{
            
        }
        
        let videoCleanApertureSettings =
            [AVVideoCleanApertureWidthKey: self.videoCaptureView.frame.size.width,
            AVVideoCleanApertureHeightKey : self.videoCaptureView.frame.size.height,
            AVVideoCleanApertureHorizontalOffsetKey:0,
            AVVideoCleanApertureVerticalOffsetKey: 0]
        
        let videoAspectRatioSettings = [AVVideoPixelAspectRatioHorizontalSpacingKey: NSNumber(int: 3), AVVideoPixelAspectRatioVerticalSpacingKey: NSNumber(int: 3)]
        
        let compressionProperties = [AVVideoCleanApertureKey: videoCleanApertureSettings,
            AVVideoPixelAspectRatioKey: videoAspectRatioSettings,
            AVVideoAverageBitRateKey: NSNumber(int: 800000),
            AVVideoMaxKeyFrameIntervalKey: NSNumber(int: 32),
            AVVideoProfileLevelKey: AVVideoProfileLevelH264BaselineAutoLevel
            
        ]
        
        let videoSettings =
        [AVVideoCodecKey: AVVideoCodecH264,
            AVVideoWidthKey: NSNumber(float:Float(self.videoCaptureView.frame.size.width)),
            AVVideoHeightKey: NSNumber(float:Float(self.videoCaptureView.frame.size.height)),
            AVVideoCompressionPropertiesKey: compressionProperties,
            AVVideoScalingModeKey: AVVideoScalingModeResizeAspectFill]
       
        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0),{
            
            print("----- 1 -----")
            let kTempMovieURL = NSURL.fileURLWithPath(self.kTempMoviePath)
            self.mMovieWriter = GPUImageMovieWriter.init(movieURL: kTempMovieURL, size: CGSizeMake(720, 960), fileType: AVFileTypeMPEG4, outputSettings: videoSettings)
            
            //self.mMovieWriter = GPUImageMovieWriter.
            
            print("----- 2 -----")
            self.mCropFilter.addTarget(self.mMovieWriter)
            
            print("----- 3 -----")
            self.mVideoCamera.audioEncodingTarget = self.mMovieWriter
            
            print("----- 4 -----")
            self.mMovieWriter.startRecording()
            
            print("----- 5 ------")
        })
    }
    
    func videoStartGesture(gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == UIGestureRecognizerState.Ended {
            print("Video UIGestureRecognizerStateEnded");
            self.didPressActiveVideo()
            //Do Whatever You want on End of Gesture
        }
        else if gestureRecognizer.state == UIGestureRecognizerState.Began{
            print("Video UIGestureRecognizerStateBegan.");
            self.recordVideoMessage()
            //Do Whatever You want on Began of Gesture
        }
        else if gestureRecognizer.state == UIGestureRecognizerState.Cancelled{
            print("Video UIGestureRecognizerStateCancel.");
            //Do Whatever You want on Began of Gesture
        }
    }
    
    func audioStartGesture(gestureRecognizer: UILongPressGestureRecognizer){
        if gestureRecognizer.state == UIGestureRecognizerState.Ended {
            self.didPressActiveRecord()
            print("Audio UIGestureRecognizerStateEnded");
            //Do Whatever You want on End of Gesture
        }
        else if gestureRecognizer.state == UIGestureRecognizerState.Began{
            self.recordAudioMessage()
            print("Audio UIGestureRecognizerStateBegan.");
            //Do Whatever You want on Began of Gesture
        }
        else if gestureRecognizer.state == UIGestureRecognizerState.Cancelled{
            print("Audio UIGestureRecognizerStateCancel.");
            //Do Whatever You want on Began of Gesture
        }
    }
    
    func recordVideoMessage() {
        self.mCounterDuringVideoTimer = 0
        
        self.keyboardController!.textView!.resignFirstResponder()
        self.inputToolbar?.contentView!.textView!.resignFirstResponder()
        self.hidesNavBar()
        
        var mBtnRotate : UIButton!
        
        mBtnRotate = UIButton.init(frame: CGRectMake(UIScreen.mainScreen().bounds.size.width / 2 - 20, 20, 40, 40))
        
        mBtnRotate.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        mBtnRotate.setImage(UIImage.init(named: "camera_img_rotate.png"), forState: UIControlState.Normal)
        mBtnRotate.addTarget(self, action: "onTouchBtnFlip:", forControlEvents: .TouchUpInside)
        
        /////// Camera Video Capture View ///////////
        if self.constraintNextBottom == 0{
            self.videoCaptureView = UIView.init(frame: CGRectMake(0, 0,
                UIScreen.mainScreen().bounds.size.width,
                UIScreen.mainScreen().bounds.size.height - 40))
            
            self.videoBackgroundView = UIView.init(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height - 40))
        }
        else{
            self.videoCaptureView = UIView.init(frame: CGRectMake(60, 20,
                UIScreen.mainScreen().bounds.size.width - 120,
                UIScreen.mainScreen().bounds.size.height - self.constraintNextBottom - 80))
            
            self.videoBackgroundView = UIView.init(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height - self.constraintNextBottom - 40))
        }
        
        videoBackgroundView.backgroundColor = UIColor.blackColor()
        videoCaptureView.backgroundColor = UIColor.grayColor()
        
        ///////// Active icon //////////////
        
        let imageActive = UIImage.init(named: Images.ChatVidRecordMsg)
        let recordBtn = UIButton.init(frame: CGRectMake(20, 8, (imageActive?.size.width)!, (imageActive?.size.height)!))
        
        recordBtn.setImage(imageActive, forState: UIControlState.Normal)
        
        recordView = UIView.init(frame: CGRectMake(0, 7, UIScreen.mainScreen().bounds.width, (imageActive?.size.height)!))
        
        recordView.addSubview(recordBtn)
        
        ////////////////////////////////////////////
        
        let imageStop : UIImage!
        let imageVideo: UIImage!
        
        let stopBtn: UIButton!
        let videoBtn: UIButton!
        
        if UIScreen.mainScreen().bounds.width == 320{
            imageStop = UIImage.init(named: Images.ChatAudioMsg)
            
            stopBtn = UIButton.init(frame: CGRectMake(UIScreen.mainScreen().bounds.width / 320 * 237, 0, (imageStop?.size.width)!, (imageStop?.size.height)!))
            
            stopBtn.setImage(imageStop, forState: UIControlState.Normal)
            //stopBtn.addTarget(self, action: "didPressActiveRecord:", forControlEvents: .TouchUpInside)
            
            ///////// Unactive vecord Audio icon //////////////
            imageVideo = UIImage.init(named: Images.ChatActiveVideoMsg)
            videoBtn = UIButton.init(frame: CGRectMake(UIScreen.mainScreen().bounds.width / 320 * 237 + (imageStop?.size.width)! + 10, 0,
                (imageVideo?.size.width)!, (imageVideo?.size.height)!))
            
            videoBtn.setImage(imageVideo, forState: UIControlState.Normal)
            
            recordView.addSubview(stopBtn)
            recordView.addSubview(videoBtn)
            ////////////////////////////////////////////
            
            //////// UILabel --- Time ////////
            textDuration = UILabel.init(frame: CGRectMake(UIScreen.mainScreen().bounds.width / 6, 0, 100,
                (imageStop?.size.height)!))
            //textDuration.text = "00:15"
            textDuration.font = UIFont(name: "Helvetica Neue", size: 15)
            textDuration.textColor = UIColor.grayColor()
            recordView.addSubview(textDuration)
        }
        else if UIScreen.mainScreen().bounds.width == 375{
            imageStop = UIImage.init(named: Images.ChatAudioMsg)
            
            stopBtn = UIButton.init(frame: CGRectMake(UIScreen.mainScreen().bounds.width / 375 * 291, 0, (imageStop?.size.width)!, (imageStop?.size.height)!))
            
            stopBtn.setImage(imageStop, forState: UIControlState.Normal)
            //stopBtn.addTarget(self, action: "didPressActiveRecord:", forControlEvents: .TouchUpInside)
            
            ///////// Unactive vecord Audio icon /////////
            imageVideo = UIImage.init(named: Images.ChatActiveVideoMsg)
            videoBtn = UIButton.init(frame: CGRectMake(UIScreen.mainScreen().bounds.width / 375 * 291 + (imageStop?.size.width)! + 10, 0,
                (imageVideo?.size.width)!, (imageVideo?.size.height)!))
            
            videoBtn.setImage(imageVideo, forState: UIControlState.Normal)
            
            recordView.addSubview(stopBtn)
            recordView.addSubview(videoBtn)
            ////////////////////////////////////////////
            
            //////// UILabel --- Time ////////
            lblVideoDuration = UILabel.init(frame: CGRectMake(UIScreen.mainScreen().bounds.width / 6, 0, 100,
                (imageStop?.size.height)!))
            //textDuration.text = "00:15"
            lblVideoDuration.font = UIFont(name: "Helvetica Neue", size: 15)
            lblVideoDuration.textColor = UIColor.grayColor()
            recordView.addSubview(lblVideoDuration)
            
        }
        
        //////// UILabel --- Time ////////
        //lblVideoDuration = UILabel.init(frame: CGRectMake(UIScreen.mainScreen().bounds.width / 6, 0, 100, (imageStop?.size.height)!))
        //textDuration.text = "00:15"
        //lblVideoDuration.textColor = UIColor.grayColor()
        
        //recordView.addSubview(lblVideoDuration)
        
        //////// Slide to cancel /////////
        let textSlide = UILabel.init(frame: CGRectMake(UIScreen.mainScreen().bounds.width / 320 * 140, 0, 120, 30))
        //textDuration.text = "00:15"
        textSlide.text = "Slide to Cancel >"
        textSlide.font = UIFont(name: "Helvetica Neue", size: 15)
        //textSlide.titleLabel!.font = UIFont(name: "Helvetica Neue", size: 10)
        textSlide.textColor = UIColor.grayColor()
        recordView.addSubview(textSlide)
        
        self.inputToolbar!.contentView?.leftBarButtonItem!.hidden = true
        self.inputToolbar!.contentView?.rightBarButtonItem!.hidden = true
        self.inputToolbar!.contentView?.rightBarButtonContainerView?.hidden = true
        
        let videoGesture = UISwipeGestureRecognizer(target: self, action: Selector("swipeVideoGesture:"))
        videoGesture.direction = UISwipeGestureRecognizerDirection.Right
        //UILongPressGestureRecognizer(target: self, action: Selector("bringItemToFront:"))
        self.inputToolbar!.contentView?.addGestureRecognizer(videoGesture)
        
        self.keyboardController!.textView?.hidden = true
        
        self.inputToolbar!.contentView?.addSubview(recordView)
        
        
        if self.mDuringVideoTimer != nil {
            self.mDuringVideoTimer?.invalidate()
            self.mDuringVideoTimer = nil;
        }
        
        self.mCounterDuringVideoTimer = 0
        
        self.mDuringVideoTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "refreshVideoTimerLabel", userInfo: nil, repeats: true)
        
        
        videoBackgroundView.addSubview(videoCaptureView)
        videoBackgroundView.addSubview(mBtnRotate)
        self.view.addSubview(videoBackgroundView)
        
        self.setupCameraForVideo()
        self.startRecVideo()
    }
    
    func swipeVideoGesture (gestureRecognizer: UISwipeGestureRecognizer){
        self.didPressActiveVideo()
    }
    
    func swipeAudioGesture (gestureRecognizer: UISwipeGestureRecognizer){
        self.didPressActiveRecord()
    }
    
    func didPressVideoButton(sender: UIButton!) {
        //self.openCameraButton()
        videoRecordView = UIView.init(frame: CGRectMake(UIScreen.mainScreen().bounds.size.width / 10, UIScreen.mainScreen().bounds.size.height / 5,
            UIScreen.mainScreen().bounds.size.width / 5 * 4,
            UIScreen.mainScreen().bounds.size.height / 5 * 3))
        videoRecordView.backgroundColor = UIColor.blackColor()
        
        self.keyboardController!.textView!.resignFirstResponder()
        videoView.hidden = true
        
        ///////// Record status icon //////////////
        
        let imageVideoRecStatus = UIImage.init(named: Images.ChatVideoRecordMsg)
        recVideoStatusBtn = UIButton.init(frame: CGRectMake(10, 20,
            ((imageVideoRecStatus?.size.width)! / 2), ((imageVideoRecStatus?.size.height)! / 2)))
        
        recVideoStatusBtn.setImage(imageVideoRecStatus, forState: UIControlState.Normal)
        videoRecordView.addSubview(recVideoStatusBtn)
        recVideoStatusBtn.hidden = true
        /////////////////////////////////////////////////
        
        ///////// Record Label icon //////////////
        
        lblVideoStatus = UILabel.init(frame: CGRectMake(40, 20, 100, 30))
        lblVideoStatus.text = "RECORDING"
        lblVideoStatus.textColor = UIColor.redColor()
        lblVideoStatus.font = UIFont(name: "Helvetica Niue", size: 10)
        
        videoRecordView.addSubview(lblVideoStatus)
        lblVideoStatus.hidden = true
        /////////////////////////////////////////////////
        
        ///////// Record Label icon //////////////
        
        lblVideoDuration = UILabel.init(frame: CGRectMake(UIScreen.mainScreen().bounds.size.width / 5 * 4 - 50,
            20, 50, 30))
        //lblVideoDuration.text = "00:15"
        lblVideoDuration.textColor = UIColor.redColor()
        lblVideoDuration.font = UIFont(name: "Helvetica Niue", size: 10)

        videoRecordView.addSubview(lblVideoDuration)
        lblVideoDuration.hidden = true
        /////////////////////////////////////////////////
        
        
        ///////// Record icon //////////////
        
        let imageVideoRec = UIImage.init(named: Images.ChatVideoRecordMsg)
        let recVideoBtn = UIButton.init(frame: CGRectMake(UIScreen.mainScreen().bounds.size.width / 5 * 2 - 30,
            UIScreen.mainScreen().bounds.size.height / 5 * 3 - 60,
            (imageVideoRec?.size.width)!, (imageVideoRec?.size.height)!))
        
        recVideoBtn.setImage(imageVideoRec, forState: UIControlState.Normal)
        recVideoBtn.addTarget(self, action: "didStartVideoCapture:", forControlEvents: .TouchUpInside)
        videoRecordView.addSubview(recVideoBtn)
        /////////////////////////////////////////////////
        
        ///////// Camera Video View //////////////
        
        let recVideoView = UIView.init(frame: CGRectMake(20, 60,
            UIScreen.mainScreen().bounds.size.width / 5 * 4 - 40,
            UIScreen.mainScreen().bounds.size.width / 5 * 4 - 40))
        
        recVideoView.backgroundColor = UIColor.grayColor()
        videoRecordView.addSubview(recVideoView)
        /////////////////////////////////////////////////
        
        self.inputToolbar!.contentView?.alpha = 0.5
        //self.collectionView?.hidden = true
        self.collectionView?.alpha = 0.5
        
        
        super.view.addSubview(videoRecordView)
        //self.view.addSubview(videoRecordView)
    }
    
    func initCamera(){
        if self.mVideoCamera != nil {
            if self.mMovieWriter != nil {
                self.mVideoCamera.audioEncodingTarget = nil
                self.mMovieWriter = nil;
                NSThread.sleepForTimeInterval(1.0)
            }
            
            self.mVideoCamera = nil;
        }
        
        if self.mCropFilter != nil{
            self.mCropFilter = nil;
        }
        
        if self.mFilterView != nil{
            self.mFilterView = nil;
        }
        
        //self.videoCaptureView.subviews
        //[[mCameraView subviews]
        //    makeObjectsPerformSelector:@selector(removeFromSuperview)];

    }
    func setupCameraForVideo(){
    
        self.initCamera()
        
        self.mVideoCamera = GPUImageVideoCamera.init(sessionPreset: AVCaptureSessionPreset640x480, cameraPosition: AVCaptureDevicePosition.Back)
        
        mVideoCamera.horizontallyMirrorFrontFacingCamera = true
        
        if UIDevice.currentDevice().orientation == UIDeviceOrientation.Portrait{
            mVideoCamera.outputImageOrientation = UIInterfaceOrientation.Portrait
        } else if UIDevice.currentDevice().orientation == UIDeviceOrientation.PortraitUpsideDown{
            mVideoCamera.outputImageOrientation = UIInterfaceOrientation.PortraitUpsideDown
        } else {
            mVideoCamera.outputImageOrientation = UIInterfaceOrientation.Portrait
        }
        
        do {
            
            try mVideoCamera.inputCamera.lockForConfiguration()
            
            if mVideoCamera.inputCamera.respondsToSelector("isSmoothAutoFocusSupported"){
                if mVideoCamera.inputCamera.smoothAutoFocusSupported == true{
                    mVideoCamera.inputCamera.smoothAutoFocusEnabled = true
                }
            }
            mVideoCamera.inputCamera.unlockForConfiguration()
            
        } catch {
            
        }
        
        if mVideoCamera.inputCamera.torchAvailable == true{
            do{
                try mVideoCamera.inputCamera.lockForConfiguration()
                    
                if mTorchModeVideo == AVCaptureTorchMode.On{
                    mVideoCamera.inputCamera.torchMode = AVCaptureTorchMode.On
                }
                else if mTorchModeVideo == AVCaptureTorchMode.Auto{
                    mVideoCamera.inputCamera.torchMode = AVCaptureTorchMode.Auto
                }
                else{
                    mVideoCamera.inputCamera.torchMode = AVCaptureTorchMode.Off
                }
                
            }catch{
                
            }
            
        }
        
        
        mCropFilter = GPUImageFilter.init()
        mFilterView = GPUImageView.init(frame: CGRectMake(0, 0, self.videoCaptureView.frame.size.width, videoCaptureView.frame.size.height))
        
        //mFilterView.set
        self.videoCaptureView.addSubview(mFilterView)
        self.videoCaptureView.sendSubviewToBack(mFilterView)
        
        mCropFilter.addTarget(mFilterView)
        mVideoCamera.addTarget(mCropFilter)
        
        mVideoCamera.startCameraCapture()
        
        /*
        mCropFilter = [[GPUImageFilter alloc] init];
        //    [mCropFilter setCropRegion:CGRectMake(0.0, 0.0, 1.0, 1.0)];
    
        mFilterView = [[GPUImageView alloc] initWithFrame:CGRectMake(0, 0, mCameraView.frame.size.width, mCameraView.frame.size.height)];
        [mFilterView setFillMode: kGPUImageFillModePreserveAspectRatioAndFill];
        [mCameraView addSubview:mFilterView];
        [mCameraView sendSubviewToBack:mFilterView];
    
        [mCropFilter addTarget:mFilterView];
        [mVideoCamera addTarget:mCropFilter];
        [mVideoCamera startCameraCapture];
    
    
        //filter = [[GPUImageFilter alloc] init];
        //force the output to 300*300
        //[filter forceProcessingAtSize:((GPUImageView*)mFilterView).sizeInPixels];
    
        //[filter addTarget:mFilterView];
        */
    }
    
    func didStartVideoCapture(sender: UIButton!){
        if self.mVideoRecStatus == false{
            self.mCounterDuringVideoTimer = 0
            self.mVideoRecStatus = true
            
            self.recVideoStatusBtn.hidden = false
            self.lblVideoStatus.hidden = false
            self.lblVideoDuration.hidden = false
            
            mDuringVideoTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "refreshVideoTimerLabel", userInfo: nil, repeats: true)
        }
        else{
            self.mVideoRecStatus = false
            
            self.videoRecordView.hidden = true
            
            self.inputToolbar!.contentView?.alpha = 1.0
            self.collectionView?.alpha = 1.0
            
            if mDuringVideoTimer != nil {
                self.mCounterDuringVideoTimer = 0
                mDuringVideoTimer!.invalidate()
                mDuringVideoTimer = nil;
            }
        }
        
    }
    
    func didPressCameraButton(sender: UIButton!) {
        //self.keyboardController.
        self.keyboardController!.textView!.resignFirstResponder()
        videoView.hidden = true
        self.openCameraButton()
    }
    
    func didPressCancelButton(sender: UIButton!) {
        self.keyboardController!.textView!.resignFirstResponder()
        self.videoView.hidden = true
    }
    
    //Recored Whilr the user is holding the audio button
    //func recordAudioMessage(sender: UIButton!)
    func recordAudioMessage() {
        
        self.mCounterDuringTimer = 0
        
        ///////// Active icon //////////////
        
        let imageActive = UIImage.init(named: Images.ChatRecordMsg)
        let recordBtn = UIButton.init(frame: CGRectMake(20, 5, (imageActive?.size.width)!, (imageActive?.size.height)!))
        
        recordBtn.setImage(imageActive, forState: UIControlState.Normal)
        
        recordView = UIView.init(frame: CGRectMake(0, 7, UIScreen.mainScreen().bounds.width, (imageActive?.size.height)!))
        
        recordView.addSubview(recordBtn)
        ////////////////////////////////////////////
        
        print(UIScreen.mainScreen().bounds.width)
        ///////// Record Audio icon ////////////
        
        let imageStop : UIImage!
        let imageVideo: UIImage!
        
        let stopBtn: UIButton!
        let videoBtn: UIButton!
        
        if UIScreen.mainScreen().bounds.width == 320{
            imageStop = UIImage.init(named: Images.ChatActiveAudioMsg)
            
            stopBtn = UIButton.init(frame: CGRectMake(UIScreen.mainScreen().bounds.width / 320 * 237, 0, (imageStop?.size.width)!, (imageStop?.size.height)!))
            
            stopBtn.setImage(imageStop, forState: UIControlState.Normal)
            //stopBtn.addTarget(self, action: "didPressActiveRecord:", forControlEvents: .TouchUpInside)
            
            ///////// Unactive vecord Audio icon //////////////
            imageVideo = UIImage.init(named: Images.ChatVideoMsg)
            videoBtn = UIButton.init(frame: CGRectMake(UIScreen.mainScreen().bounds.width / 320 * 237 + (imageStop?.size.width)! + 10, 0,
                (imageVideo?.size.width)!, (imageVideo?.size.height)!))
            
            videoBtn.setImage(imageVideo, forState: UIControlState.Normal)
            
            recordView.addSubview(stopBtn)
            recordView.addSubview(videoBtn)
            ////////////////////////////////////////////
            
            //////// UILabel --- Time ////////
            textDuration = UILabel.init(frame: CGRectMake(UIScreen.mainScreen().bounds.width / 6, 0, 100,
                (imageStop?.size.height)!))
            //textDuration.text = "00:15"
            textDuration.font = UIFont(name: "Helvetica Neue", size: 15)
            textDuration.textColor = UIColor.grayColor()
            recordView.addSubview(textDuration)
        }
        else if UIScreen.mainScreen().bounds.width == 375{
            imageStop = UIImage.init(named: Images.ChatActiveAudioMsg)
            
            stopBtn = UIButton.init(frame: CGRectMake(UIScreen.mainScreen().bounds.width / 375 * 291, 0, (imageStop?.size.width)!, (imageStop?.size.height)!))
            
            stopBtn.setImage(imageStop, forState: UIControlState.Normal)
            //stopBtn.addTarget(self, action: "didPressActiveRecord:", forControlEvents: .TouchUpInside)
            
            ///////// Unactive vecord Audio icon //////////////
            imageVideo = UIImage.init(named: Images.ChatVideoMsg)
            videoBtn = UIButton.init(frame: CGRectMake(UIScreen.mainScreen().bounds.width / 375 * 291 + (imageStop?.size.width)! + 10, 0,
                (imageVideo?.size.width)!, (imageVideo?.size.height)!))
            
            videoBtn.setImage(imageVideo, forState: UIControlState.Normal)
            
            recordView.addSubview(stopBtn)
            recordView.addSubview(videoBtn)
            ////////////////////////////////////////////
            
            //////// UILabel --- Time ////////
            textDuration = UILabel.init(frame: CGRectMake(UIScreen.mainScreen().bounds.width / 6, 0, 100,
                (imageStop?.size.height)!))
            //textDuration.text = "00:15"
            textDuration.font = UIFont(name: "Helvetica Neue", size: 15)
            textDuration.textColor = UIColor.grayColor()
            recordView.addSubview(textDuration)

        }
        
        //////// Slide to cancel /////////
        let textSlide = UILabel.init(frame: CGRectMake(UIScreen.mainScreen().bounds.width / 320 * 115, 0, 120, 30))
        //textDuration.text = "00:15"
        textSlide.text = "Slide to Cancel >"
        textSlide.font = UIFont(name: "Helvetica Neue", size: 15)
        textSlide.textColor = UIColor.grayColor()
        
        recordView.addSubview(textSlide)
        
        self.inputToolbar!.contentView?.leftBarButtonItem!.hidden = true
        self.inputToolbar!.contentView?.rightBarButtonItem!.hidden = true
        self.inputToolbar!.contentView?.rightBarButtonContainerView?.hidden = true
        
        let audioGesture = UISwipeGestureRecognizer(target: self, action: Selector("swipeAudioGesture:"))
        audioGesture.direction = UISwipeGestureRecognizerDirection.Right
        //UILongPressGestureRecognizer(target: self, action: Selector("bringItemToFront:"))
        self.inputToolbar!.contentView?.addGestureRecognizer(audioGesture)
        
        self.keyboardController.textView?.resignFirstResponder()
        self.keyboardController!.textView?.hidden = true
        
        self.inputToolbar!.contentView?.addSubview(recordView)
        
        mDuringTimer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "refreshTimerLabel", userInfo: nil, repeats: true)
        startRecording()
        //if sender.state == UIGestureRecognizerState.Began {
            
        //} else if sender.state == UIGestureRecognizerState.Ended {
            
        //    finishRecording(success: true)
        //}
    }
    
    func refreshVideoTimerLabel(){
        self.mCounterDuringVideoTimer++
        
        //if self.mCounterDuringVideoTimer > 4 {
        //    self.mCounterDuringVideoTimer = 4;
        //    self.didPressActiveVideo()
        //}
        //textDuration
        self.lblVideoDuration.text = NSString(format: "00:%02d", self.mCounterDuringVideoTimer) as String
    }
    
    func refreshTimerLabel(){
        self.mCounterDuringTimer++
        
        //if self.mCounterDuringTimer > 4 {
            //self.mCounterDuringTimer = 4;
            //self.didPressActiveRecord()
        //}
        //textDuration
        self.textDuration.text = NSString(format: "00:%02d", self.mCounterDuringTimer) as String
    }
    
    func removeFile(filePath: NSString!){
        let fileManager : NSFileManager! = NSFileManager.defaultManager()
        
        let err: NSError!
        
        do{
            try fileManager.removeItemAtPath(filePath as String)
        }
        catch{
//            print("Could not delete %s", err.localizedDescription)
        }
    }
    
    func onTouchBtnFlip(sender: UIButton!){
        mVideoCamera.rotateCamera()
    }
    
    func onFinishRecordVideo(){
        print("Finished Record Video")
        
        let movieURL : NSURL = NSURL.fileURLWithPath(self.kTempMoviePath)
        let videoMediaItem = WJSQVideoMediaItem.init(fileURL: movieURL, isReadyToPlay: true)
        let message = MessageData(senderId: self.senderId, senderDisplayName: senderDisplayName, date: NSDate(), media: videoMediaItem)
        
        let fileName = self.saveFileToParse(NSData(contentsOfURL: movieURL)!)
        
        //self.saveMediaToParse(message, data: NSData(contentsOfURL: movieURL)!, fileName:"videoFile")
        
        if (dateMessage.compare("Today") != NSComparisonResult.OrderedSame){
            
            dateMessage = "Today"
            let dateItem = WJSQDateItem.init()
            dateItem.dateString = dateMessage
            
            var jsqMessage : MessageData!
            jsqMessage = MessageData(senderId: senderId, senderDisplayName: senderDisplayName, date: NSDate(), media: dateItem)
            jsqMessage.status = "title"
            
            self.messages.append(jsqMessage)
            
            print("same")
        }
        
        message.status = "pending"
        self.messages += [message]
        
        //self.publishMessageToChannel(message)
        self.publishMediaToChannel(fileName, type: "video")
        self.finishSendingMessage()
    }
    
    func trimVideo(){
        self.kCapturedMoviePath = NSTemporaryDirectory() + "/capture.mov"
        self.removeFile(self.kCapturedMoviePath)
        
        let videoURL: NSURL! = NSURL.fileURLWithPath(self.kTempMoviePath)
        
        let anAsset : AVAsset! = AVAsset.init(URL: videoURL)
        
        let imageGenerator : AVAssetImageGenerator! = AVAssetImageGenerator.init(asset: anAsset)
        imageGenerator.appliesPreferredTrackTransform = true
        
        let time : CMTime! = CMTimeMake(1, 5)
        
        var imageRef : CGImageRef!
        do{
           try imageRef = imageGenerator.copyCGImageAtTime(time, actualTime: nil)
        }
        catch{
            
        }
        
        let compatiblePresets: NSArray! = AVAssetExportSession.exportPresetsCompatibleWithAsset(anAsset)
        
        if compatiblePresets.containsObject(AVAssetExportPresetHighestQuality){

            var exportSession : AVAssetExportSession!
            exportSession = AVAssetExportSession.init(asset: anAsset, presetName: AVAssetExportPresetPassthrough)
            
            // Implementation continues.
            let furl: NSURL! = NSURL.fileURLWithPath(self.kCapturedMoviePath)
            
            exportSession.outputURL = furl
            exportSession.outputFileType = AVFileTypeQuickTimeMovie
            
            
            
            let start: CMTime! = CMTimeMakeWithSeconds(0, anAsset.duration.timescale)
            let duration: CMTime! = CMTimeMakeWithSeconds(CMTimeGetSeconds(anAsset.duration) - Float64(anAsset.duration.timescale) * 0.5, anAsset.duration.timescale)
            
            let range : CMTimeRange! = CMTimeRangeMake(start, duration)
            exportSession.timeRange = range
            
            exportSession.exportAsynchronouslyWithCompletionHandler(){
                if exportSession.status == AVAssetExportSessionStatus.Failed{
                    
                    print("Export failed: %s", exportSession.error?.localizedDescription);
                }else if exportSession.status == AVAssetExportSessionStatus.Cancelled{
                    
                    print("Export cancelled: ");
                }else if exportSession.status == AVAssetExportSessionStatus.Completed{
                    
                    dispatch_async(dispatch_get_main_queue()){
                        print("Succes")
                    NSNotificationCenter.defaultCenter().postNotificationName("NOTIF_DID_FINISH_RECORD_VIDEO", object: nil)
                        
                    }
                    
                }else{
                    print("None")
                }
                
            }
        }
        
        
        
    }
    
    //func didPressActiveVideo(sender: UIButton!) {
    func didPressActiveVideo() {
        
        self.inputToolbar!.contentView?.leftBarButtonItem!.hidden = false
        self.inputToolbar!.contentView?.rightBarButtonItem!.hidden = false
        self.inputToolbar!.contentView?.rightBarButtonContainerView?.hidden = false
        self.keyboardController!.textView?.hidden = false
        
        recordView.hidden = true
        
        self.videoBackgroundView.hidden = true
        self.videoCaptureView.hidden = true
        
        self.showNavBar()
        
        self.mMovieWriter.finishRecordingWithCompletionHandler(){
            if self.mDuringVideoTimer != nil {
                self.mCounterDuringVideoTimer = 0
                self.mDuringVideoTimer!.invalidate()
                self.mDuringVideoTimer = nil;
            }
            
            self.mVideoCamera.audioEncodingTarget = nil
            self.mMovieWriter.finishRecording()
            
            self.mMovieWriter = nil;
            
            self.trimVideo()
        }
        //finishRecording(success: true)
    }
    
    //func didPressActiveRecord(sender: UIButton!)
    func didPressActiveRecord() {
        
        self.inputToolbar!.contentView?.leftBarButtonItem!.hidden = false
        self.inputToolbar!.contentView?.rightBarButtonItem!.hidden = false
        self.inputToolbar!.contentView?.rightBarButtonContainerView?.hidden = false
        self.keyboardController!.textView?.hidden = false
        
        recordView.hidden = true
        
        finishRecording(success: true)
        
        if mDuringTimer != nil {
            self.mCounterDuringTimer = 0
            mDuringTimer!.invalidate()
            mDuringTimer = nil;
        }
        
        
    }
    
    class func getDocumentsDirectory() -> NSString {
        
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true) as [String]
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    class func getRecordURL() -> NSURL {
        
        let audioFilename = getDocumentsDirectory().stringByAppendingPathComponent("record.m4a")
        let audioURL = NSURL(fileURLWithPath: audioFilename)
        
        return audioURL
    }
    
    //Record
    func startRecording() {
        
        let audioURL = ChatViewController.getRecordURL()
        print(audioURL.absoluteString)
        
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000.0,
            AVNumberOfChannelsKey: 1 as NSNumber,
            AVEncoderAudioQualityKey: AVAudioQuality.High.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(URL: audioURL, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
        } catch {
            
            finishRecording(success: false)
        }
    }
    
    //Finish recording and send the message
    func finishRecording(success success: Bool) {
        
        audioRecorder.stop()
        audioRecorder = nil
        
        let data : NSData = NSData(contentsOfURL: ChatViewController.getRecordURL())!
        
        audioDuration = NSString(format: "00:%02d", self.mCounterDuringTimer) as String
        let audioMediaItem = WJSQAudioMediaItem.init(fileURL: ChatViewController.getRecordURL(), isReadyToPlay: true)
        
        let message = MessageData(senderId: self.senderId, senderDisplayName: senderDisplayName, date: NSDate(), media:audioMediaItem)
        
        let fileName = self.saveFileToParse(data)
        
        //self.mCounterDuringTimer
        //self.saveMediaToParse(message, data: data, fileName:"audioFile")
        message.status = "pending"
        self.messages += [message]
        //self.publishMessageToChannel(message)
        
        self.publishMediaToChannel(fileName, type: "audio")
        self.finishSendingMessage()
        
    }
}

// #MARK - PubNub

extension ChatViewController : PNObjectEventListener {
    
    //Setup PubNub
    func setup() {

        self.client = PubNub.clientWithConfiguration(self.config)
        self.client?.addListener(self)
        self.client?.subscribeToChannels([self.passedChatId], withPresence: true)
        self.view.addSubview(self.imageView)
        self.imageView.hidden = true
        
        
        self.client?.addPushNotificationsOnChannels([self.passedChatId], withDevicePushToken: gTokenString.dataUsingEncoding(NSUTF8StringEncoding), andCompletion: { (status) -> Void in
            if !status.error{
                // Handle successful push notification enabling on passed channels.
                print ("this Push notification")
            }
            else{
                // Handle modification error. Check 'category' property
                // to find out possible reason because of which request did fail.
                // Review 'errorData' property (which has PNErrorData data type) of status
                // object to get additional information about issue.
                //
                // Request can be resent using: status.retry()
                print ("this Push notification error")
            }
        })
        
        let appManager : AppManager = AppManager.appManagerSharedInstance()
        let defaults = NSUserDefaults.standardUserDefaults()
        appManager.currentUser.userId = defaults.stringForKey("guid")

        self.senderId = appManager.currentUser.userId
        if self.senderId == nil {
            self.senderId = UIDevice.currentDevice().identifierForVendor!.UUIDString
        }
        
        self.senderDisplayName = UIDevice.currentDevice().identifierForVendor?.UUIDString
        self.loadMessagesFromPubNub()
        self.showLoadEarlierMessagesHeader = false
        self.collectionView?.reloadData()
        
    }
    
    override func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        if text == "\n" {
            if self.keyboardController.textView?.text == ""{
                return false
            }
            self.didPressSendButton(nil, withMessageText:self.keyboardController.textView?.text , senderId:self.senderId , senderDisplayName: self.senderDisplayName, date: NSDate())
            return false
        }
        
        return true
    }
    
    func publishMediaToChannel(mediaName: String, type: String) {
        
        var msg = [String:AnyObject]()
        msg["type"] = type
        msg["senderId"] = self.senderId
        msg["status"] = "pending"
        msg["body"] = mediaName
        msg["senderDisplayName"] = senderDisplayName
        msg["date"] = NSDate().timeIntervalSince1970
        
        var aStr : String
        if type == "audio"{
            msg["duration"] = NSString(format: "00:%02d", self.mCounterDuringTimer) as String
            
            aStr = String(format: "%@ posted audio on your channel.", self.myUser.userName)
            print (aStr)
            
            self.client?.publish(nil, toChannel: self.passedChatId, mobilePushPayload: ["aps" : ["alert" : aStr]], withCompletion: { (status) -> Void in
                print("\(status.debugDescription)")
            })
        }
        else if type == "video"{
            msg["duration"] = ""
            
            aStr = String(format: "%@ posted video on your channel.", self.myUser.userName)
            print (aStr)
            
            self.client?.publish(nil, toChannel: self.passedChatId, mobilePushPayload: ["aps" : ["alert" : aStr]], withCompletion: { (status) -> Void in
                print("\(status.debugDescription)")
            })
        }
        else if type == "photo"{
            aStr = String(format: "%@ posted photo on your channel.", self.myUser.userName)
            print (aStr)
            
            self.client?.publish(nil, toChannel: self.passedChatId, mobilePushPayload: ["aps" : ["alert" : aStr]], withCompletion: { (status) -> Void in
                print("\(status.debugDescription)")
            })
        }
        
        self.client?.publish(msg, toChannel: self.passedChatId, storeInHistory: true, compressed: false, withCompletion: nil)
    }
    
    func publishMessageToChannel(message:JSQMessage) {
        
        /*var msg = [String:AnyObject]()
        msg["type"] = "text"
        msg["senderId"] = message.senderId
        msg["body"] = message.text
        msg["senderDisplayName"] = message.senderDisplayName
        msg["date"] = message.date*/
        
        let msg = ["type": "text", "senderId": message.senderId, "status": "pending", "body": message.text, "senderDisplayName": message.senderDisplayName, "date": message.date.timeIntervalSince1970]
        
        var aStr = String(format: "%@ : %@", self.myUser.userName, message.text)
        print (aStr)
        
        self.client?.publish(msg, toChannel: self.passedChatId, storeInHistory: true, compressed: false, withCompletion: nil)
        
        self.client?.publish(nil, toChannel: self.passedChatId, mobilePushPayload: ["aps" : ["alert" : aStr]], withCompletion: { (status) -> Void in
            print("\(status.debugDescription)")
        })
        
//        self.client?.publish(message.text, toChannel: "test", compressed: false, withCompletion: nil)
        //self.client?.publish(message.text, toChannel: self.passedChatId, storeInHistory: true, compressed: false, withCompletion: nil)
        
    }

    func client(client: PubNub!, didReceiveMessage message: PNMessageResult!) {
        // Handle new message stored in message.data.message
        
        if message.data.actualChannel != nil {
            
            // Message has been received on channel group stored in
            // message.data.subscribedChannel
            
            //self.loadMessagesFromParse()
        }
        else {
            
            // Message has been received on channel stored in
            // message.data.subscribedChannel
            
            //self.loadMessagesFromParse()
        }
        
        print("Received message: \(message.data.message) on channel " +
            "\((message.data.actualChannel ?? message.data.subscribedChannel)!) at " +
            "\(message.data.timetoken)")
        
        if let msgDict = message?.data?.message as? [String: AnyObject] {
            if (msgDict["senderId"] as? String) == self.senderId {
                
                let received_date = NSDate(timeIntervalSince1970: (floor((msgDict["date"] as? NSTimeInterval)!)))
                
                for mess in self.messages{
                    
                    let formatter = NSDateFormatter()
                    formatter.dateStyle = NSDateFormatterStyle.MediumStyle
                    formatter.timeStyle = .MediumStyle
                    
                    let dateString = formatter.stringFromDate(mess.date)
                    let dateReceiveString = formatter.stringFromDate(received_date)
                    //print(mess.status)
                    
                    if dateString.compare(dateReceiveString) == NSComparisonResult.OrderedSame{
                        //.isEqualToDate(mess.date){
                        mess.status = "approved"
                        self.collectionView?.reloadData()
                    }

                }
                return
            }
        }
        
        if let msg = self.jsqMessageFromPubNubMessage(message?.data?.message) {
            if msg.status == "apns"{
                return
            }
            msg.status = "approved"
            self.messages.append(msg)
            self.collectionView?.reloadData()
        }
    }
    
    func client(client: PubNub!, didReceivePresenceEvent event: PNPresenceEventResult!) {
        // Handle presence event event.data.presenceEvent (one of: join, leave, timeout,
        // state-change).
        if event.data.actualChannel != nil {
            
            // Presence event has been received on channel group stored in
            // event.data.subscribedChannel
        }
        else {
            
            // Presence event has been received on channel stored in
            // event.data.subscribedChannel
        }
        
        
        if event.data.presenceEvent != "state-change" {
            
            print("\(event.data.presence.uuid) \"\(event.data.presenceEvent)'ed\"\n" +
                "at: \(event.data.presence.timetoken) " +
                "on \((event.data.actualChannel ?? event.data.subscribedChannel)!) " +
                "(Occupancy: \(event.data.presence.occupancy))");
        }
        else {
            
            print("\(event.data.presence.uuid) changed state at: " +
                "\(event.data.presence.timetoken) " +
                "on \((event.data.actualChannel ?? event.data.subscribedChannel)!) to:\n" +
                "\(event.data.presence.state)");
        }
    }
    
    // Handle subscription status change.
    func client(client: PubNub!, didReceiveStatus status: PNStatus!) {
        if status.category == .PNUnexpectedDisconnectCategory {
            
            // This event happens when radio / connectivity is lost
        }
        else if status.category == .PNConnectedCategory {
            
            // Connect event. You can do stuff like publish, and know you'll get it.
            // Or just use the connected event to confirm you are subscribed for
            // UI / internal notifications, etc
            
            // Select last object from list of channels and send message to it.
            //let targetChannel = client.channels().last as! String
//            client.publish("Hello from the PubNub Swift SDK", toChannel: targetChannel,
//                compressed: false, withCompletion: { (status) -> Void in
//                    
//                    if !status.error {
//                        
//                        // Message successfully published to specified channel.
//                    }
//                    else{
//                        
//                        // Handle message publish error. Check 'category' property
//                        // to find out possible reason because of which request did fail.
//                        // Review 'errorData' property (which has PNErrorData data type) of status
//                        // object to get additional information about issue.
//                        //
//                        // Request can be resent using: status.retry()
//                    }
//            })
        }
        else if status.category == .PNReconnectedCategory {
            
            // Happens as part of our regular operation. This event happens when
            // radio / connectivity is lost, then regained.
        }
        else if status.category == .PNDecryptionErrorCategory {
            
            // Handle messsage decryption error. Probably client configured to
            // encrypt messages and on live data feed it received plain text.
        }
    }
}

////MARK - Data Source
extension ChatViewController {
    
    //Initialize back button on navigtion bar
    func initNavBar() {
        
        self.navItem!.showHomeBackBtn()
        //self.navItem!.showBackLeftBtn()
        
        (self.navItem.rightBarButtonItems![0].customView as! UIButton).addTarget(self, action: "privetAction:", forControlEvents: UIControlEvents.TouchUpInside)
        (self.navItem.rightBarButtonItems![1].customView as! UIButton).addTarget(self, action: "myProfileAction:", forControlEvents: UIControlEvents.TouchUpInside)
        
        self.taBar.hidden = true
        self.view.bringSubviewToFront(self.taBar)
        //(self.navItem.leftBarButtonItem?.customView as! UIButton).addTarget(self, action: "backAction:", forControlEvents: UIControlEvents.TouchUpInside)
        (self.navItem.leftBarButtonItems![0].customView as! UIButton).addTarget(self, action: "backAction:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    func privetAction(sender:AnyObject) {
        self.showAlertPrivateView("Dive", message: "You can go to\"off line\" mode for browsing contacts in private mode")
        
    }
    
    func showAlertPrivateView(title: String, message: String) {
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
    
    func myProfileAction(sender:AnyObject) {
        let vc = self.storyboard?.instantiateViewControllerWithIdentifier("vcUserFacebookDetails") as? UserFacebookDetailsViewController
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    // Show navigation bar
    func showNavBar() {
        self.navigationController?.navigationBarHidden = false
        
    }
    //Hide navigation bar
    func hidesNavBar() {
        self.navigationController?.navigationBarHidden = true
        
    }
    
    func backAction(sender:AnyObject) {
        
        if !self.imageView.hidden {
            
            self.imageView.hidden = true
            self.imageView.image = nil
            
        } else {
            
            self.navigationController!.popViewControllerAnimated(true)
        }
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        print(self.messages.count)
        return self.messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        print("indexPath row Number")
        print(indexPath.row)
        let data = self.messages[indexPath.row]
        
        return data
    }
    

    //override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
    //    print(indexPath.row)
    //    let data = self.messages[indexPath.row]
    //    return data
    //}
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, didDeleteMessageAtIndexPath indexPath: NSIndexPath!) {
        
        self.messages.removeAtIndex(indexPath.row)
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        
        let data = messages[indexPath.row]
        
        //Show incoming/outgoinf bubble according to sender id
        switch(data.senderId) {
            
        case self.senderId:
            return self.outgoingBubble
            break
        default:
            return self.incomingBubble
        }
    }
    
    //Handle bubble tap
    override func collectionView(collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAtIndexPath indexPath: NSIndexPath!) {
        
        let data:JSQMessage = messages[indexPath.row]
        if data.media != nil {
            
            //Handle image bubble tap
            if data.media.isKindOfClass(WJSQPhotoMediaItem) {
                
                let imageItem : WJSQPhotoMediaItem = data.media as! WJSQPhotoMediaItem
                let image = imageItem.image
                self.imageView.image = image
                self.imageView.backgroundColor = UIColor.blackColor()
                self.imageView.contentMode = UIViewContentMode.ScaleAspectFit
                
                self.headerView.hidden = true
                
                self.imageView.hidden = false
            //Handle video bubble tap
            } else if data.media.isKindOfClass(WJSQVideoMediaItem) {
                
                let videoItem = data.media as! WJSQVideoMediaItem
                
                let player = AVPlayer(URL: videoItem.fileURL!)
                self.moviePlayer = AVPlayerViewController()
                self.moviePlayer.player = player
                self.presentViewController(self.moviePlayer, animated: true, completion: nil)
                player.play()
                
            //Handle audio bubble tap
            } else if data.media.isKindOfClass(WJSQAudioMediaItem) {
                
                //let audioItem = data.media as! WJSQAudioMediaItem
                //try! audioPlayer = AVAudioPlayer(contentsOfURL: audioItem.fileURL)
                //audioPlayer.play()
                
                let audioItem = data.media as! WJSQAudioMediaItem
                
                let player = AVPlayer(URL: audioItem.fileURL!)
                self.moviePlayer = AVPlayerViewController()
                self.moviePlayer.player = player
                self.presentViewController(self.moviePlayer, animated: true, completion: nil)
                player.play()
            }
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        return nil
    }
    
    //override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    
    //}
    
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell
        
        //Text message apperance
        if cell.textView != nil {
            cell.textView!.textColor = UIColor.darkGrayColor()
            cell.textView!.font = UIFont(name: cell.textView!.font!.fontName, size: 16)
        }
        
        let data:JSQMessage = messages[indexPath.row]
        
        if data.isMediaMessage == false
        {
            let customAttributes : JSQMessagesCollectionViewLayoutAttributes = self.collectionView?.layoutAttributesForItemAtIndexPath(indexPath) as! JSQMessagesCollectionViewLayoutAttributes
            
            customAttributes.messageBubbleContainerViewWidth = UIScreen.mainScreen().bounds.width - 100
            cell.applyLayoutAttributes(customAttributes)
        }

        return cell
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
       
        //Show name and date for message
        print(indexPath.item)
        let message = messages[indexPath.item];
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let phoneNumber = defaults.stringForKey("phoneNumber")
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "hh:mm:ss"
        let dateString = dateFormatter.stringFromDate(message.date)
        
        if message.isMediaMessage == true{
            if message.media.isKindOfClass(WJSQDateItem){
                return NSAttributedString (string: "")
            }
        }
        
        if self.passedType == "user"{
            
            if message.senderId == self.senderId {
                //{SN} add phone number next to time
                //return NSAttributedString(string:dateString + " " + phoneNumber!)
                if message.status.compare("approved") == NSComparisonResult.OrderedSame{
                    return NSAttributedString( string: " Me " + dateString + " ✅✅")
                }
                else if message.status.compare("pending") == NSComparisonResult.OrderedSame{
                    return NSAttributedString( string: " Me " + dateString + " ✅")
                }
                else{
                    return NSAttributedString( string: " Me " + dateString )
                }
                
            }
            
            if indexPath.item > 0 {
                let previousMessage = messages[indexPath.item - 1];
                if previousMessage.senderDisplayName == message.senderDisplayName {
                    return NSAttributedString(string:dateString)
                }
            }
            
            if self.otherUser != nil{
                if message.status.compare("approved") == NSComparisonResult.OrderedSame{
                    return NSAttributedString( string: self.otherUser.userName + " " + dateString + " ✅✅")
                }
                else if message.status.compare("pending") == NSComparisonResult.OrderedSame{
                    return NSAttributedString( string: " Me " + dateString + " ✅")
                }
                else{
                    return NSAttributedString(string: self.otherUser.userName + " " + dateString)
                }
                
            }
            
            
            return NSAttributedString(string: self.otherUser == nil ? "" : self.otherUser.userName + " " + dateString)
        }
        else if self.passedType == "group"{
            
            if  message.senderId == self.senderId {
                //{SN} add phone number next to time
                //return NSAttributedString(string:dateString + " " + phoneNumber!)
                if message.status.compare("approved") == NSComparisonResult.OrderedSame{
                    return NSAttributedString( string: " Me " + dateString + " ✅✅")
                }
                else if message.status.compare("pending") == NSComparisonResult.OrderedSame{
                    return NSAttributedString( string: " Me " + dateString + " ✅")
                }
                else{
                    return NSAttributedString( string: " Me " + dateString )
                }
            }
            
            if indexPath.item > 0 {
                let previousMessage = messages[indexPath.item - 1];
                if previousMessage.senderDisplayName == message.senderDisplayName {
                    return NSAttributedString(string:dateString)
                }
            }
            
            var userdata: User!
            for userdata in self.groupUsers{
                if message.senderId == userdata.userId{
                    if message.status.compare("approved") == NSComparisonResult.OrderedSame{
                        return NSAttributedString( string: userdata.userName + " " + dateString + " ✅✅")
                    }
                    else if message.status.compare("pending") == NSComparisonResult.OrderedSame{
                        return NSAttributedString( string: " Me " + dateString + " ✅")
                    }
                    else{
                        return NSAttributedString( string: userdata.userName + " " + dateString)
                    }
                    
                }
                
            }
            
            
        }
        
        return NSAttributedString(string: self.otherUser == nil ? "" : self.otherUser.userName + " " + dateString)
        
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        print(indexPath.item)
        let message = messages[indexPath.item];
        
        let defaults = NSUserDefaults.standardUserDefaults()
        let phoneNumber = defaults.stringForKey("phoneNumber")
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "hh:mm"
        let dateString = dateFormatter.stringFromDate(message.date)
        
        if message.isMediaMessage == true{
            if message.media.isKindOfClass(WJSQDateItem){
                return NSAttributedString (string: "")
            }
        }        
        
        if self.passedType == "user"{
            if message.senderId == self.senderId {
                //{SN} add phone number next to time
                //return NSAttributedString(string:dateString + " " + phoneNumber!)
                if message.status.compare("approved") == NSComparisonResult.OrderedSame{
                    return NSAttributedString( string: " Me " + dateString + " ✅✅")
                }
                else if message.status.compare("pending") == NSComparisonResult.OrderedSame{
                    return NSAttributedString( string: " Me " + dateString + " ✅")
                }
                else{
                    return NSAttributedString( string: " Me " + dateString )
                }
            }
            
            if indexPath.item > 0 {
                let previousMessage = messages[indexPath.item - 1];
                if previousMessage.senderDisplayName == message.senderDisplayName {
                    return NSAttributedString(string:dateString)
                }
            }
            
            if self.otherUser != nil{
                return NSAttributedString(string: self.otherUser.userName + " " + dateString)
            }
            return NSAttributedString(string: self.otherUser == nil ? "" : self.otherUser.userName + " " + dateString)
        }
        else if self.passedType == "group"{
            
            if  message.senderId == self.senderId {
                //{SN} add phone number next to time
                //return NSAttributedString(string:dateString + " " + phoneNumber!)
                if message.status.compare("approved") == NSComparisonResult.OrderedSame{
                    return NSAttributedString( string: " Me " + dateString + " ✅✅")
                }
                else if message.status.compare("pending") == NSComparisonResult.OrderedSame{
                    return NSAttributedString( string: " Me " + dateString + " ✅")
                }
                else{
                    return NSAttributedString( string: " Me " + dateString )
                }
            }
            
            if indexPath.item > 0 {
                let previousMessage = messages[indexPath.item - 1];
                if previousMessage.senderDisplayName == message.senderDisplayName {
                    return NSAttributedString(string:dateString)
                }
            }
            
            var userdata: User!
            for userdata in self.groupUsers{
                if message.senderId == userdata.userId{
                    if message.status.compare("approved") == NSComparisonResult.OrderedSame{
                        return NSAttributedString( string: userdata.userName + " " + dateString + " ✅✅")
                    }
                    else if message.status.compare("pending") == NSComparisonResult.OrderedSame{
                        return NSAttributedString( string: " Me " + dateString + " ✅")
                    }
                    else{
                        return NSAttributedString( string: userdata.userName + " " + dateString)
                    }
                }
            }
        }
        
        return NSAttributedString(string: self.otherUser == nil ? "" : self.otherUser.userName + " " + dateString)
        
    }
//    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
//        
//        let message = messages[indexPath.item];
//        
//        let dateFormatter = NSDateFormatter()
//        dateFormatter.dateFormat = "hh:mm"
//        let dateString = dateFormatter.stringFromDate(message.date)
//        
//        let monthAndDayFormatter = NSDateFormatter()
//        dateFormatter.dateFormat = "DD:MM:YYYY"
//        
//        if indexPath.item > 0 {
//            
//            let previousMessage = messages[indexPath.item - 1];
//            let previousDateString = monthAndDayFormatter.stringFromDate(previousMessage.date)
//            let newDateString = monthAndDayFormatter.stringFromDate(message.date)
//            
//        }
//        
//        return NSAttributedString(string: dateString)
//    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        let message = messages[indexPath.item]
        
//        if message.senderId == senderId {
//            return CGFloat(0.0);
//        }
        print(indexPath.item)
        
        if (message.isMediaMessage == true){
            if message.media.isKindOfClass(WJSQDateItem){
                return CGFloat(0.0);
            }
        }
        
        if indexPath.item > 0 {
            let previousMessage = messages[indexPath.item - 1];
            if previousMessage.senderDisplayName == message.senderDisplayName {
                return CGFloat(30.0);
            }
        }
        
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
}


//MARK - Toolbar
extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate  {
    
    //Handle send button tap
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        
        //If tapped button is audio button - ignore
        if button == self.inputToolbar?.contentView?.rightBarButtonItem {
            self.inputToolbar?.contentView!.textView!.resignFirstResponder()
            return
        }
        
        //Send the message
        let message = MessageData(senderId: senderId, senderDisplayName: senderDisplayName, date: NSDate(), text: text)
        
        if (dateMessage.compare("Today") != NSComparisonResult.OrderedSame){
            
            dateMessage = "Today"
            let dateItem = WJSQDateItem.init()
            dateItem.dateString = dateMessage
            
            var jsqMessage : MessageData!
            jsqMessage = MessageData(senderId: senderId, senderDisplayName: senderDisplayName, date: NSDate(), media: dateItem)
            
            jsqMessage.status = "title"
            self.messages.append(jsqMessage)
            
            print("same")
        }
        
        message.status = "pending"

        self.messages += [message]
        self.publishMessageToChannel(message)
//        self.saveMessageToParse(message)
        self.finishSendingMessage()
    }
    
    func deleteLastMessage()
    {
        //let nLastIndex : Int = messages.count
        let data : JSQMessage = messages.last!
        
        self.messages.removeAtIndex(messages.count - 1)
        self.collectionView?.reloadData()
        //self.client?.r
    }
    
    func didPressOption(sender: UIButton!) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        alert.addAction(UIAlertAction(title: "Delete My Last Message", style: UIAlertActionStyle.Default, handler: {
            (alert: UIAlertAction!) -> Void in
//            self.openCameraButton()
            self.deleteLastMessage()
            
        }))
        
        alert.addAction(UIAlertAction(title: "Block User", style: UIAlertActionStyle.Default, handler: {
            (alert: UIAlertAction!) -> Void in
//            self.photofromLibrary()
        }))
        
        alert.addAction(UIAlertAction(title: "Report User", style: UIAlertActionStyle.Default, handler: {
            (alert: UIAlertAction!) -> Void in
//            self.shareLocation()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func didPressAccessoryButton(sender: UIButton!) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        alert.addAction(UIAlertAction(title: "Photo/Video Library", style: UIAlertActionStyle.Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.photofromLibrary()
        }))
        
        alert.addAction(UIAlertAction(title: "Share Location", style: UIAlertActionStyle.Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.shareLocation()
        }))
        
        alert.addAction(UIAlertAction(title: "Use the Camera", style: UIAlertActionStyle.Default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.openCameraButton()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    //MARK: Delegates
    
    func photofromLibrary() {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            imagePicker.mediaTypes = [kUTTypeMovie as String, kUTTypeImage as String, kUTTypeVideo as String]
            imagePicker.allowsEditing = true
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    func openCameraButton() {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.Camera;
            imagePicker.allowsEditing = false
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    func shareLocation() {
        
        //if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            
        //    let imagePicker = UIImagePickerController()
        //    imagePicker.delegate = self
        //    imagePicker.sourceType = UIImagePickerControllerSourceType.Camera;
        //    imagePicker.allowsEditing = false
        //    self.presentViewController(imagePicker, animated: true, completion: nil)
        //}
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        print("print Finish picking image")
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        let mediaType = info[UIImagePickerControllerMediaType] as? String
        
        //Send chosen image
        if mediaType == kUTTypeImage as String {
            
            var chosenImage = info[UIImagePickerControllerEditedImage] as? UIImage
            if chosenImage == nil {
                chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage
            }
            self.dismissViewControllerAnimated(true, completion: nil)
            
            let photoMediaItem = WJSQPhotoMediaItem.init(image: chosenImage)
            let message = MessageData(senderId: self.senderId, senderDisplayName: senderDisplayName, date: NSDate(), media: photoMediaItem)
            
            if (dateMessage.compare("Today") != NSComparisonResult.OrderedSame){
                
                dateMessage = "Today"
                let dateItem = WJSQDateItem.init()
                dateItem.dateString = dateMessage
                
                var jsqMessage : MessageData!
                jsqMessage = MessageData(senderId: senderId, senderDisplayName: senderDisplayName, date: NSDate(), media: dateItem)
                jsqMessage.status = "title"
                
                self.messages.append(jsqMessage)
                
                print("same")
            }
            
            message.status = "pending"
//            self.saveMediaToParse(message, data: UIImagePNGRepresentation(chosenImage!)!, fileName:"imageFile")

            let fileName = self.saveFileToParse(UIImageJPEGRepresentation(chosenImage!, 0.8)!)
            self.messages += [message]
//            self.publishMessageToChannel(message)
            self.publishMediaToChannel(fileName, type: "photo")
            self.finishSendingMessage()
            
        //Send chosen video
        } else if (mediaType == kUTTypeVideo as String) || (mediaType ==  kUTTypeMovie as String) {
            
            let movieURL = info[UIImagePickerControllerMediaURL] as? NSURL
            let videoMediaItem = WJSQVideoMediaItem.init(fileURL: movieURL, isReadyToPlay: true)
            let message = MessageData(senderId: self.senderId, senderDisplayName: senderDisplayName, date: NSDate(), media: videoMediaItem)
            
            if (dateMessage.compare("Today") != NSComparisonResult.OrderedSame){
                
                dateMessage = "Today"
                let dateItem = WJSQDateItem.init()
                dateItem.dateString = dateMessage
                
                var jsqMessage : MessageData!
                jsqMessage = MessageData(senderId: senderId, senderDisplayName: senderDisplayName, date: NSDate(), media: dateItem)
                jsqMessage.status = "title"
                
                self.messages.append(jsqMessage)
                
                print("same")
            }
            
            message.status = "pending"
            
            let fileName = self.saveFileToParse(NSData(contentsOfURL: movieURL!)!)
            //self.saveMediaToParse(message, data: NSData(contentsOfURL: movieURL!)!, fileName:"videoFile")
            self.messages += [message]
            //self.publishMessageToChannel(message)
            
            self.publishMediaToChannel(fileName, type: "video")
            self.finishSendingMessage()
        }
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK - Parse
extension ChatViewController {
    
    func fillMediaFromParse(message: MessageData, mediaName: String, type: String) {
        let query = PFQuery(className: "files")
        //query.orderByAscending("date")
        query.whereKey("name", equalTo: mediaName)
        query.getFirstObjectInBackgroundWithBlock {[weak self] object, error in
            
            guard let sself = self else { return }
            
            if let file = object?["file"] as? PFFile {
                file.getDataInBackgroundWithBlock({[weak self] (data, error) -> Void in
                    guard let sself = self else { return }
                    if let data = data where error == nil {
                        dispatch_async(dispatch_get_main_queue()) {[weak self] in
                            guard let sself = self else { return }
                            var outgoing = false
                            
                            if message.senderId == sself.senderId {
                                outgoing = true
                            }
                            
                            if type == "photo" {
                                
                                let image = UIImage(data: data)
                                let photoMediaItem = WJSQPhotoMediaItem.init(image: image)
                                photoMediaItem.appliesMediaViewMaskAsOutgoing = outgoing
                                message.setValue(photoMediaItem, forKey: "media")
                                
                            } else if type == "video" {
                                
                                let dataStr = NSTemporaryDirectory() + "/" + mediaName + ".mov"
                                data.writeToFile(dataStr, atomically: true)
                                let movieUrl = NSURL(fileURLWithPath: dataStr)
                                let videoMediaItem = WJSQVideoMediaItem.init(fileURL: movieUrl, isReadyToPlay:true)
                                videoMediaItem.appliesMediaViewMaskAsOutgoing = outgoing
                                message.setValue(videoMediaItem, forKey: "media")
                                
                            } else if type == "audio" {
                                
                                let dataStr = NSTemporaryDirectory() + "/" + mediaName + ".m4a"
                                data.writeToFile(dataStr, atomically: true)
                                let audioUrl = NSURL(fileURLWithPath: dataStr)
                                
                                let audioMediaItem = WJSQAudioMediaItem.init(fileURL: audioUrl, isReadyToPlay:true)
                                audioMediaItem.appliesMediaViewMaskAsOutgoing = outgoing
                                message.setValue(audioMediaItem, forKey: "media")
                            }
                            
                            
                            if let index = sself.messages.indexOf(message) {
                                let indexPath = NSIndexPath(forItem: index, inSection: 0)
                                sself.collectionView?.reloadItemsAtIndexPaths([indexPath])
                            }
                        }
                    }
                })
            } else {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1.0 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {[weak self] () -> Void in
                    guard let sself = self else { return }
                    sself.fillMediaFromParse(message, mediaName: mediaName, type: type)
                })
            }
        }
    }
    
    func stringFromTimeInterval(startDate: NSDate, endDate: NSDate) -> (String){
        
        let cal = NSCalendar.currentCalendar()
        
        let unitFlags: NSCalendarUnit = [.Year, .Month, .Day, .Weekday]
        let breakdownInfo: NSDateComponents = cal.components(unitFlags, fromDate: startDate, toDate: endDate, options: [])
    
        if (breakdownInfo.month > 0){
            if (breakdownInfo.month == 1){
                return "a month ago"
            }else{
                return String(format: "%d months ago", breakdownInfo.month)
            }
        }
        
        if (breakdownInfo.day > 0){
            if (breakdownInfo.day == 1){
                return "Yesterday"
            }else if (breakdownInfo.day <= 7){
                
                return String(format: "%d days ago", breakdownInfo.day)
            }
            else{
                let formatter = NSDateFormatter()
                formatter.dateStyle = NSDateFormatterStyle.MediumStyle
                //formatter.timeStyle = .MediumStyle
                
                let dateString = formatter.stringFromDate(startDate)
                return dateString
            }
        }
        
        /*if (breakdownInfo.hour > 0){
            if (breakdownInfo.month == 1){
                return "an hour ago"
            }else{
                return String(format: "%d hours ago", breakdownInfo.hour)
            }
        }
        
        if (breakdownInfo.minute > 0){
            if (breakdownInfo.month == 1){
                return "a min ago"
            }else{
                return String(format: "%d mins ago", breakdownInfo.minute)
            }
        }*/
        
        return "Today";
    }
    
    func jsqMessageFromPubNubMessage(message: AnyObject?) -> MessageData?{
        
        guard let message = message else {
            return nil
        }
        
        if let message = message as? [String: AnyObject] {
            let type = (message["type"] as? String) ?? ""
            let body = (message["body"] as? String) ?? ""
            let senderId = (message["senderId"] as? String) ?? ""
            let senderDisplayName = (message["senderDisplayName"] as? String) ?? ""
            let duration = (message["duration"] as? String) ?? ""
            let date = (message["date"] as? NSTimeInterval) ?? 0
            
            let pn_apn = (message["pn_apns"] as? String) ?? ""
            
            if type == ""{
                let jsqMessage = MessageData(senderId: senderId, senderDisplayName: senderDisplayName, date: NSDate(timeIntervalSince1970: date) , text: body)
                jsqMessage.status = "apns"
                return jsqMessage
            }
            
            let mess_date = NSDate(timeIntervalSince1970: date)
            let curr_date = NSDate()
            
            let period = stringFromTimeInterval(mess_date, endDate: curr_date)
            if (dateMessage.compare(period) != NSComparisonResult.OrderedSame){
                
                dateMessage = period
                let dateItem = WJSQDateItem.init()
                dateItem.dateString = dateMessage
            
                var jsqMessage : MessageData!
                jsqMessage = MessageData(senderId: senderId, senderDisplayName: senderDisplayName, date: NSDate(timeIntervalSince1970: date), media: dateItem)
                
                jsqMessage.status = "title"
                //jsqMessage = JSQMessage(senderId: senderId, senderDisplayName: senderDisplayName, date: NSDate(timeIntervalSince1970: date), text: dateMessage)
                self.messages.append(jsqMessage)
            
                print("same")
            }
            
            if type == "text" {
                let jsqMessage = MessageData(senderId: senderId, senderDisplayName: senderDisplayName, date: NSDate(timeIntervalSince1970: date) , text: body)
                jsqMessage.status = ""
                return jsqMessage
            } else {
                
                var jsqMessage : MessageData!
                if type == "audio"{
                    let dataStr = NSTemporaryDirectory() + "/" + "1.m4a"
                    
                    let audioUrl = NSURL(fileURLWithPath: dataStr)
                    audioDuration = duration
                    let audioMediaItem = WJSQAudioMediaItem.init(fileURL: audioUrl, isReadyToPlay:true)
                
                    jsqMessage = MessageData(senderId: senderId, senderDisplayName: senderDisplayName, date: NSDate(timeIntervalSince1970: date), media: audioMediaItem)
                    jsqMessage.status = ""
                    
                    //jsqMessage = JSQMessage(
                    
                }
                else{
                    let imageThumbnail = UIImage.init(named: Images.ChatEmpty)
                    
                    let photoMediaItem = WJSQPhotoMediaItem.init(image: imageThumbnail)
                    
                    jsqMessage = MessageData(senderId: senderId, senderDisplayName: senderDisplayName, date: NSDate(timeIntervalSince1970: date), media: photoMediaItem)
                    jsqMessage.status = ""
                }
                
                self.fillMediaFromParse(jsqMessage, mediaName: body, type:type)
                return jsqMessage
            }
        } else if let message = message as? String {
            let jsqMessage = MessageData(senderId: self.senderId, senderDisplayName: senderDisplayName, date: NSDate(), text: message)
            jsqMessage.status = "message"
            return jsqMessage
        }
        return nil
    }
    
    func loadMessagesFromPubNub() {
        self.client?.historyForChannel(self.passedChatId, withCompletion: { result, status in
            if status == nil || !status.error {
                if let messages = result?.data?.messages {
                    for message in messages {
                        if let msg = self.jsqMessageFromPubNubMessage(message) {
                            if msg.status == "apns" || msg.status == "message"{
                                continue
                            }
                            msg.status = "approved"
                            self.messages.append(msg)
                        }
                    }
                }
            }
            
            self.collectionView?.reloadData()
            self.scrollToBottomAnimated(true)
        })
    }
    
    //Load history from parse
    func loadMessagesFromParse() {
        
        var videoNum = 0
        var audioNum = 0
        
        let query = PFQuery(className: "chattingHistory")
        //query.orderByAscending("date")
        query.orderByAscending("date")
        query.whereKey("channel", equalTo: self.passedChatId)
        
        query.findObjectsInBackgroundWithBlock { (objects, error) -> Void in
            
            print(query.limit)
            
            if self.messageOriginNum == 0{
                self.messageOriginNum = (objects?.count)!
                self.flgChanged = 0
            }
            else if self.messageOriginNum <= (objects?.count){
                self.messageOriginNum = (objects?.count)!
                self.flgChanged = 1
            }
            
            //objects?.count
            if(error != nil) {
                NSLog("Error getting messages: %@",(error?.localizedDescription)!)
                return
            }
            
            if let objects = objects {
                var jsqMessage:MessageData!
                
                for message in objects {
                    
                    if self.flgChanged == 1{
                        if self.indexMessage < self.messageOriginNum{
                            self.indexMessage++
                            continue
                        }
                    }
                    
                    if  message["body"] != nil {
                        var date = NSDate()
                        if message["date"] != nil {
                            date = message["date"] as! NSDate
                        }
                        //jsqMessage = JSQMessage(senderId: message["senderId"] as! String, displayName: message["senderDisplayName"] as! String, text: message["body"] as! String)
                        jsqMessage = MessageData(senderId: message["senderId"] as! String, senderDisplayName: message["senderDisplayName"] as! String, date: date , text: message["body"] as! String)
                        print(jsqMessage.date);
                        
                        self.messages.append(jsqMessage)
                        //self.collectionView?.reloadData()
                        self.scrollToBottomAnimated(true)
                        
                    //current message is image
                    } else if message["imageFile"] != nil {
                        message["imageFile"].getDataInBackgroundWithBlock({ (data, error) -> Void in
                            if let data = data where error == nil {
                                dispatch_async(dispatch_get_main_queue()) {

                                    let image = UIImage(data: data)
                                    let photoMediaItem = WJSQPhotoMediaItem.init(image: image)
                                    photoMediaItem.appliesMediaViewMaskAsOutgoing = self.isMediaOutgoing(message)
                                    var date = NSDate()
                                    if message["date"] != nil {
                                        date = message["date"] as! NSDate
                                    }
                                    jsqMessage = MessageData(senderId: message["senderId"] as! String, senderDisplayName: message["senderDisplayName"] as! String, date: date, media: photoMediaItem)
                                    self.messages.append(jsqMessage)
                                    self.collectionView?.reloadData()
                                    self.scrollToBottomAnimated(true)
                                }
                            }
                        })
                        
                    //current message is video
                    } else if message["videoFile"] != nil {
                        
                        message["videoFile"].getDataInBackgroundWithBlock({ (data, error) -> Void in
                            if let data = data where error == nil {
                                dispatch_async(dispatch_get_main_queue()) {
                                    videoNum++

                                    let dataStr = NSTemporaryDirectory() + String(videoNum) + ".mov"
                                    data.writeToFile(dataStr, atomically: true)
                                    let movieUrl = NSURL(fileURLWithPath: dataStr)
                                    let videoMediaItem = WJSQVideoMediaItem.init(fileURL: movieUrl, isReadyToPlay:true)
                                    videoMediaItem.appliesMediaViewMaskAsOutgoing = self.isMediaOutgoing(message)
                                    var date = NSDate()
                                    if message["date"] != nil {
                                        date = message["date"] as! NSDate
                                    }
                                    jsqMessage = MessageData(senderId: message["senderId"] as! String, senderDisplayName: message["senderDisplayName"] as! String, date: date, media: videoMediaItem)
                                    self.messages.append(jsqMessage)
                                    self.collectionView?.reloadData()
                                    self.scrollToBottomAnimated(true)
                                }
                            }
                        })
                        
                    //current message is audio
                    }  else if message["audioFile"] != nil {
                        
                        message["audioFile"].getDataInBackgroundWithBlock({ (data, error) -> Void in
                            if let data = data where error == nil {
                                dispatch_async(dispatch_get_main_queue()) {
                                    audioNum++
                                    
                                    let dataStr = NSTemporaryDirectory() + String(videoNum) + ".m4a"
                                    data.writeToFile(dataStr, atomically: true)
                                    let audioUrl = NSURL(fileURLWithPath: dataStr)
                                    
                                    let audioMediaItem = WJSQAudioMediaItem.init(fileURL: audioUrl, isReadyToPlay:true)
                                    audioMediaItem.appliesMediaViewMaskAsOutgoing = self.isMediaOutgoing(message)
                                    var date = NSDate()
                                    if message["date"] != nil {
                                        date = message["date"] as! NSDate
                                    }
                                    jsqMessage = MessageData(senderId: message["senderId"] as! String, senderDisplayName: message["senderDisplayName"] as! String, date: date, media: audioMediaItem)
                                    self.messages.append(jsqMessage)
                                    self.collectionView?.reloadData()
                                    self.scrollToBottomAnimated(true)
                                }
                            }
                            })
                    }
                    //self.messages.append(jsqMessage)
                }
            }
            
            self.collectionView?.reloadData()
            self.scrollToBottomAnimated(true)
        }
    }
    
    func isMediaOutgoing(message: PFObject) -> Bool {
        
        if message["senderId"] as! String == self.senderId {
            return true
        }
        
        return false
    }
    
    //Save text message to parse
    func saveMessageToParse(message:JSQMessage) {
        
//        let msg = PFObject(className: "test_channel")
        let msg = PFObject(className: "chattingHistory")
        print(message.senderId)
        print(message.date)
        msg["senderId"] = message.senderId
        msg["body"] = message.text
        msg["senderDisplayName"] = message.senderDisplayName
        msg["date"] = message.date
        msg["channel"] = [self.passedChatId]
        if PFUser.currentUser() != nil {
            msg["user"] = PFUser.currentUser()
        }
        msg.saveInBackgroundWithBlock { (success, error) -> Void in
            if(error != nil) {
                NSLog("error: %@",(error?.localizedDescription)!)
            }
        }
    }
    
    func saveFileToParse(data: NSData) -> String {
        
        let appManager : AppManager = AppManager.appManagerSharedInstance();
        
        let name = NSUUID().UUIDString + appManager.currentUser.userId;
        let dataFile = PFFile(data: data);
        let fileObj = PFObject(className: "files");
        fileObj["name"] = name;
        fileObj["file"] = dataFile;
        fileObj.saveInBackgroundWithBlock { (success, error) -> Void in
            if(error != nil) {
                NSLog("error: %@",(error?.localizedDescription)!)
            }
        }
        
        return name
    }
    
    // Save media message to parse
    func saveMediaToParse(message:JSQMessage, data:NSData, fileName:String) {
        
        let dataFile = PFFile.init(data: data)
        let msg = PFObject(className: "chattingHistory")
        msg["senderId"] = message.senderId
        msg[fileName] = dataFile
        msg["date"] = message.date
        msg["senderDisplayName"] = message.senderDisplayName
        msg["channel"] = [self.passedChatId]
        if PFUser.currentUser() != nil {
            msg["user"] = PFUser.currentUser()
        }
        
        msg.saveInBackgroundWithBlock { (success, error) -> Void in
            if(error != nil) {
                NSLog("error: %@",(error?.localizedDescription)!)
            }
        }
    }
}

