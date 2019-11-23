//
//  UnlockButton.swift
//  DoorMan
//
//  Created by Attawit Kittikrairit on 9/4/15.
//  Copyright (c) 2015 Attawit Kittikrairit. All rights reserved.
//

import UIKit
import QuartzCore
import Alamofire
import FBSDKCoreKit
import FBSDKLoginKit

class UnlockButton: UIView {
    @IBOutlet var messageBox: UIView?
    @IBOutlet var messageText: UILabel?
    var running = false
    var device = [String: String]()
    var defaults: NSUserDefaults!
    
    //#536270
    let untouchedColorR = CGFloat(83.0/255.0)
    let untouchedColorG = CGFloat(98.0/255.0)
    let untouchedColorB = CGFloat(112.0/255.0)
    
    // #3F4E5C
    let touchedColorR = CGFloat(63.0/255.0)
    let touchedColorG = CGFloat(78.0/255.0)
    let touchedColorB = CGFloat(92.0/255.0)
    
    let alphaColor = CGFloat(1.0)
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        layer.cornerRadius = 3;
        layer.masksToBounds = true;
        
        defaults = NSUserDefaults.init(suiteName: "DoorManShared")
        
        // Load Device ID
        if(defaults.objectForKey("Device") != nil) {
            self.device = defaults.objectForKey("Device") as! [String: String]
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName("Device", object: nil, queue: nil, usingBlock: gotDevice)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.backgroundColor = UIColor(red: touchedColorR, green: touchedColorG, blue: touchedColorB, alpha: alphaColor)
        if(self.running == false){
            sendUnlockRequest()
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.backgroundColor = UIColor(red: untouchedColorR, green: untouchedColorG, blue: untouchedColorB, alpha: alphaColor)
    }
    
    func sendUnlockRequest() {
        NSNotificationCenter.defaultCenter().postNotificationName("UnlockRequest", object: nil)
        Alamofire.request(.POST,
                          "https://www.mrttle.com/device/send",
                          parameters: [
                            "fb_access_token": FBSDKAccessToken.currentAccessToken().tokenString,
                            "id": self.device["ID"]!,
                            "message": "{\"unlock\":true}"])
            .responseData { response in
                            NSNotificationCenter.defaultCenter().postNotificationName("UnlockResponse", object: nil)
                            if response.result.isSuccess == true {
                                print("Unlock message sent")
                            } else {
                                print("Failed to send unlock message")
                            }
        }
    }
    
    func gotDevice(notification: NSNotification) {
        self.device = notification.userInfo as! [String: String]
    }
    
    func hideMessageBox() {
        self.messageBox?.hidden = true
        self.running = false
    }
}
