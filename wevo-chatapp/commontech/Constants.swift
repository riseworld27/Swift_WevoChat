//
//  Constants.swift
//  commontech
//
//  Created by matata on 17/10/2015.
//  Copyright © 2015 matata. All rights reserved.
//

import Foundation

let Instagram =
[
    "consumerKey": "f9469d014dfb455d92910ae33b9111f5",
    "consumerSecret": "313fbf56ae59429f94ef0c163a6533e0"
]
let GoogleYoutube =
[
    "consumerKey": "1051959794848-ake483c3l127ubk8u5e17hd78vevfiie.apps.googleusercontent.com",
    "consumerSecret": ""
]

//#define IS_IPHONE4 ( (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.height < 568) ? YES : NO )
//#define IS_IPHONE5 ( (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.height == 568) ? YES : NO )
//#define IS_IPHONE6 ( (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.height > 568) ? YES : NO )

var audioDuration = ""
var dateMessage = ""
var gTokenString = ""

struct Segues {
    static let SegueMain = "SegueMain"
    static let SegueSignIn = "SegueSignIn"
    static let SeguePopular = "SeguePopular"
    static let SegueGroups = "SegueGroups"
}

struct Google {
    static let ClientId = ""
}

struct Nibs {
    static let WSerachBar = "WSerachBar"
    
}

struct PubNubKeys {
    //static let PublishKey = "pub-c-d752d62f-0966-4b7f-9647-6b9e5327e0ca"
    //static let SubscribeKey = "sub-c-44b1bb72-a4cd-11e5-b8f4-0619f8945a4f"
    
    static let PublishKey = "pub-c-21895461-6d2b-4ec4-8d4b-0706387ce3bb"
    static let SubscribeKey = "sub-c-cf8ab590-c98b-11e5-a316-0619f8945a4f"
    
    //Publish Key pub-c-21895461-6d2b-4ec4-8d4b-0706387ce3bb
    //Subscribe Key sub-c-cf8ab590-c98b-11e5-a316-0619f8945a4f
    //static let PublishKey = "pub-c-21895461-6d2b-4ec4-8d4b-0706387ce3bb"
    //static let SubscribeKey = "sub-c-cf8ab590-c98b-11e5-a316-0619f8945a4f"
//    static let PublishKey = "pub-c-d752d62f-0966-4b7f-9647-6b9e5327e0ca"
//    static let SubscribeKey = "sub-c-44b1bb72-a4cd-11e5-b8f4-0619f8945a4f"
}

struct Images {
    static let ChatAudioMsg = "wevo_chat_quick_sound"
    static let ChatVideoMsg = "wevo_chat_quick_video"
    static let ChatActiveAudioMsg = "wevo_chat_quick_sound_active"
    static let ChatActiveVideoMsg = "wevo_chat_quick_vid_active"
    
    static let ChatAttachMsg = "wevo_chat_attach"
    static let ChatRecordMsg = "wevo_chat_sound_record"
    static let ChatVideoRecordMsg = "wevo_chat_record_button"
    static let ChatCameraVideoMsg = "wevo_chat_video_msg"
    
    static let ChatVidRecordMsg = "wevo_chat_vid_record"
    
    static let ChatAudioImageMsg = "wevo_chat_audio_message"
    static let ChatAudioPlayMsg = "wevo_chat_play_audio"
    
    static let ChatAudioPlayerProfile = "wevo_chat_user_non"
    static let ChatEmpty = "empty"
    static let ChatOptions = "wevo_chat_options"
    
    static let ChatIconPrivet = "wevo_icon_privet"
    static let SubscribeKey = "sub-c-cf8ab590-c98b-11e5-a316-0619f8945a4f"
}

//1051959794848-jothgjancm80vvqu5lb7o686klhvocam.apps.googleusercontent.com
