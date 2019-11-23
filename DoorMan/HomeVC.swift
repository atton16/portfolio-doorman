//
//  ViewController.swift
//  DoorMan
//
//  Created by Attawit Kittikrairit on 9/4/15.
//  Copyright (c) 2015 Attawit Kittikrairit. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class HomeVC: UIViewController {
    
    @IBOutlet var name: UILabel!
    
    var defaults: NSUserDefaults!
    var loadingAlert: UIAlertController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        defaults = NSUserDefaults.init(suiteName: "DoorManShared")
        
        FBSDKProfile.enableUpdatesOnAccessTokenChange(true)
        
        // Load title
        if(defaults.objectForKey("Device") != nil) {
            let device = defaults.objectForKey("Device") as! [String: String]
            self.title = device["name"]
        }
        
        NSNotificationCenter.defaultCenter().addObserverForName("Device", object: nil, queue: nil, usingBlock: gotDevice)
        NSNotificationCenter.defaultCenter().addObserverForName("UnlockRequest", object: nil, queue: nil, usingBlock: unlockRequestSent)
        NSNotificationCenter.defaultCenter().addObserverForName("UnlockResponse", object: nil, queue: nil, usingBlock: unlockResponseReceived)
        NSNotificationCenter.defaultCenter().addObserverForName("Login", object: nil, queue: nil, usingBlock: loggedin)
        
        // Create pairingAlert
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        loadingIndicator.center = CGPointMake(135.0, 65.5)
        loadingIndicator.color = UIColor.blackColor()
        loadingIndicator.startAnimating()
        loadingAlert = UIAlertController(title: nil, message: "Sending\n\n", preferredStyle: UIAlertControllerStyle.Alert)
        loadingAlert.view.addSubview(loadingIndicator)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
        // Direct user to Login screen if they are not yet logged in
        if ((FBSDKAccessToken.currentAccessToken()) != nil) {
            // User is logged in, do work such as go to next view controller.
            if(defaults.objectForKey("LoginScene") != nil) {
                if(defaults.integerForKey("LoginScene") == LoginVCScene.Pair.hashValue) {
                    print("Redirect to pairing")
                    performSegueWithIdentifier("HomeToLogin.Pair", sender: self)
                    return
                }
            }
            
            FBSDKProfile.loadCurrentProfileWithCompletion({ (profile: FBSDKProfile!, error: NSError!) in
                print("User is already logged in: (Name: "+FBSDKProfile.currentProfile().name+")")
                self.name.text = FBSDKProfile.currentProfile().name
            })
            return
        }
        
        // User is NOT yet logged in, redirect to login page
        print("Redirect to login")
        performSegueWithIdentifier("HomeToLogin", sender: self)
        return
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "HomeToLogin.Pair"){
            let vc = segue.destinationViewController as! LoginVC
            vc.targetScene = .Pair
        }
    }
    
    @IBAction func leftBarButtonClick(sender: AnyObject) {
        if ((FBSDKAccessToken.currentAccessToken()) != nil) {
            print("Logging out")
            self.defaults.removeObjectForKey("FullName")
            FBSDKLoginManager().logOut()
        }
        performSegueWithIdentifier("HomeToLoginAnimate", sender: self)
    }
    
    @IBAction func rightBarButtonClick(sender: AnyObject) {
        performSegueWithIdentifier("HomeToDevices", sender: self)
    }
    
    func gotDevice(notification: NSNotification) {
        let device = notification.userInfo as! [String: String]
        self.title = device["name"]!
    }
    
    func unlockRequestSent(notification: NSNotification) {
        self.presentViewController(self.loadingAlert, animated: true, completion: nil)
    }
    
    func unlockResponseReceived(notification: NSNotification) {
        self.loadingAlert.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func loggedin(notification: NSNotification) {
        self.name.text = FBSDKProfile.currentProfile().name
        self.defaults.setObject(FBSDKProfile.currentProfile().name, forKey: "FullName")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

