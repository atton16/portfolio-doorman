//
//  LoginVC.swift
//  DoorMan
//
//  Created by Attawit Kittikrairit on 6/14/16.
//  Copyright © 2016 Attawit Kittikrairit. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Alamofire

enum LoginVCScene {
    case Login, Pair
}

class LoginVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var blurredBackground: UIView!
    @IBOutlet var continueWithFacebookButton: UIButton!
    @IBOutlet var deviceIdTextField: UITextField!
    @IBOutlet var deviceIdHeaderText: UILabel!
    @IBOutlet var deviceIdFooterText: UILabel!
    @IBOutlet var deviceNameTextField: UITextField!
    @IBOutlet var pairButton: UIButton!
    @IBOutlet var gettingStartedLabel: UILabel!
    @IBOutlet var withLabel: UILabel!
    @IBOutlet var doorManLabel: UILabel!
    @IBOutlet var helloLabel: UILabel!
    @IBOutlet var firstnameLabel: UILabel!
    @IBOutlet var lastnameLabel: UILabel!
    
    @IBOutlet var continueWithFacebookButtonXConstraint: NSLayoutConstraint!
    @IBOutlet var deviceIdTextFieldXConstraint: NSLayoutConstraint!
    @IBOutlet var deviceIdHeaderTextXConstraint: NSLayoutConstraint!
    @IBOutlet var deviceIdFooterTextXConstraint: NSLayoutConstraint!
    @IBOutlet var deviceNameTextFieldXConstraint: NSLayoutConstraint!
    @IBOutlet var pairButtonXConstraint: NSLayoutConstraint!
    @IBOutlet var gettingStartedLabelXConstraint: NSLayoutConstraint!
    @IBOutlet var helloLabelXConstraint: NSLayoutConstraint!
    
    var FBLoginManager: FBSDKLoginManager!
    var defaults: NSUserDefaults!
    var targetScene: LoginVCScene?
    var loadingAlert: UIAlertController!
    var pairingAlert: UIAlertController!
    var loginFailedAlert: UIAlertController!
    var pairingFailedAlert: UIAlertController!
    var needEmailAlert: UIAlertController!
    var pairingTimer: NSTimer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        FBLoginManager = FBSDKLoginManager()
        
        FBSDKProfile.enableUpdatesOnAccessTokenChange(true)
        
        defaults = NSUserDefaults.init(suiteName: "DoorManShared")
        pairingTimer = nil
        
        // Set background to clear
        view.backgroundColor = UIColor.clearColor()
        view.opaque = false

        // Set rounded corner
        makeRoundedCorner(deviceIdTextField, radius: 3)
        makeRoundedCorner(deviceNameTextField, radius: 3)
        makeRoundedCorner(pairButton, radius: 3)
        makeRoundedCorner(continueWithFacebookButton, radius: 3)
        
        // Observe Text fields return event
        deviceIdTextField.delegate = self
        deviceNameTextField.delegate = self
        
        // Set blurred effect on background
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = blurredBackground.bounds
        blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight] // for supporting device rotation
        blurredBackground.layer.zPosition = -1
        blurredBackground.addSubview(blurEffectView)
        blurredBackground.backgroundColor = UIColor.clearColor()
        blurredBackground.opaque = false
        
        // Attach keyboard resigner
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        
        // Create loadingAlert
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        loadingIndicator.center = CGPointMake(135.0, 65.5)
        loadingIndicator.color = UIColor.blackColor()
        loadingIndicator.startAnimating()
        loadingAlert = UIAlertController(title: nil, message: "Logging in\n\n", preferredStyle: UIAlertControllerStyle.Alert)
        loadingAlert.view.addSubview(loadingIndicator)
        
        // Create pairingAlert
        let pairingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        pairingIndicator.center = CGPointMake(135.0, 65.5)
        pairingIndicator.color = UIColor.blackColor()
        pairingIndicator.startAnimating()
        pairingAlert = UIAlertController(title: nil, message: "Pairing\n\n", preferredStyle: UIAlertControllerStyle.Alert)
        pairingAlert.view.addSubview(pairingIndicator)
        
        // Create loginFailedAlert
        loginFailedAlert = UIAlertController(title: "Something Went Wrong", message: "Login failed due to unexpected condition. If the problem persist please contact Mr.Turtle.", preferredStyle: UIAlertControllerStyle.Alert)
        loginFailedAlert.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil))
        
        // Create pairingFailedAlert
        pairingFailedAlert = UIAlertController(title: "Something Went Wrong", message: "Pairing failed due to unexpected condition. If the problem persist please contact Mr.Turtle.", preferredStyle: UIAlertControllerStyle.Alert)
        pairingFailedAlert.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil))
        
        // Create needEmailAlert
        needEmailAlert = UIAlertController(title: "Email Required", message: "Please grant us an access to your email in order to use our service.", preferredStyle: UIAlertControllerStyle.Alert)
        needEmailAlert.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler: nil))
        
        // Set scene to Login
        if(targetScene == nil) {
            targetScene = .Login
        } else {
            self.getPairedDeviceCount(FBSDKAccessToken.currentAccessToken().tokenString)
            self.firstnameLabel.text = FBSDKProfile.currentProfile().firstName
            self.lastnameLabel.text = FBSDKProfile.currentProfile().lastName
        }
        setScene(targetScene!, animated: false)
        
    }
    
    func makeRoundedCorner(view: UIView, radius: CGFloat) {
        view.opaque = false
        view.layer.cornerRadius = radius
        //view.layer.masksToBounds = true
    }
    
    func dismissKeyboard() {
        deviceIdTextField.resignFirstResponder()
        deviceNameTextField.resignFirstResponder()
    }
    
    func setTargetScene(scene:LoginVCScene) {
        self.targetScene = scene
    }
    
    func setScene(scene: LoginVCScene, animated: Bool) -> Void {
        var duration = 0.2
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        let screenWidth = screenSize.width
        defaults.setInteger(scene.hashValue, forKey: "LoginScene")
        
        if animated {
            // Animation Safety
            continueWithFacebookButton.hidden = false
            deviceIdTextField.hidden = false
            deviceIdHeaderText.hidden = false
            deviceIdFooterText.hidden = false
            deviceNameTextField.hidden = false
            pairButton.hidden = false
            gettingStartedLabel.hidden = false
            withLabel.hidden = false
            doorManLabel.hidden = false
            helloLabel.hidden = false
            firstnameLabel.hidden = false
            lastnameLabel.hidden = false
            continueWithFacebookButton.setNeedsLayout()
            deviceIdTextField.setNeedsLayout()
            deviceIdHeaderText.setNeedsLayout()
            deviceIdFooterText.setNeedsLayout()
            deviceNameTextField.setNeedsLayout()
            pairButton.setNeedsLayout()
            gettingStartedLabel.setNeedsLayout()
            withLabel.setNeedsLayout()
            doorManLabel.setNeedsLayout()
            helloLabel.setNeedsLayout()
            firstnameLabel.setNeedsLayout()
            lastnameLabel.setNeedsLayout()
        } else {
            duration = 0.0
        }
        
        switch scene {
        case .Pair:
            // Setup animation
            UIView.animateWithDuration(duration, animations: {
                self.continueWithFacebookButtonXConstraint.constant = -screenWidth
                self.deviceIdTextFieldXConstraint.constant = 0.0
                self.deviceIdHeaderTextXConstraint.constant = 0.0
                self.deviceIdFooterTextXConstraint.constant = 0.0
                self.deviceNameTextFieldXConstraint.constant = 0.0
                self.pairButtonXConstraint.constant = 0.0
                self.gettingStartedLabelXConstraint.constant = -screenWidth + 36.0
                self.helloLabelXConstraint.constant = 36.0
                
                self.continueWithFacebookButton.layoutIfNeeded()
                self.deviceIdTextField.layoutIfNeeded()
                self.deviceIdHeaderText.layoutIfNeeded()
                self.deviceIdFooterText.layoutIfNeeded()
                self.deviceNameTextField.layoutIfNeeded()
                self.pairButton.layoutIfNeeded()
                self.gettingStartedLabel.setNeedsLayout()
                self.withLabel.setNeedsLayout()
                self.doorManLabel.setNeedsLayout()
                self.helloLabel.setNeedsLayout()
                self.firstnameLabel.setNeedsLayout()
                self.lastnameLabel.setNeedsLayout()
            }) { (completed) in
                // UI safety
                self.continueWithFacebookButton.hidden = true
                self.deviceIdTextField.hidden = false
                self.deviceIdHeaderText.hidden = false
                self.deviceIdFooterText.hidden = false
                self.deviceNameTextField.hidden = false
                self.pairButton.hidden = false
                self.gettingStartedLabel.hidden = true
                self.withLabel.hidden = true
                self.doorManLabel.hidden = true
                self.helloLabel.hidden = false
                self.firstnameLabel.hidden = false
                self.lastnameLabel.hidden = false
                
            }
        default:
            // Setup animation
            UIView.animateWithDuration(duration, animations: {
                self.continueWithFacebookButtonXConstraint.constant = 0.0
                self.deviceIdTextFieldXConstraint.constant = screenWidth
                self.deviceIdHeaderTextXConstraint.constant = screenWidth
                self.deviceIdFooterTextXConstraint.constant = screenWidth
                self.deviceNameTextFieldXConstraint.constant = screenWidth
                self.pairButtonXConstraint.constant = screenWidth
                self.gettingStartedLabelXConstraint.constant = 36.0
                self.helloLabelXConstraint.constant = screenWidth + 36.0
                self.continueWithFacebookButton.layoutIfNeeded()
                self.deviceIdTextField.layoutIfNeeded()
                self.deviceIdHeaderText.layoutIfNeeded()
                self.deviceIdFooterText.layoutIfNeeded()
                self.deviceNameTextField.layoutIfNeeded()
                self.pairButton.layoutIfNeeded()
                self.gettingStartedLabel.setNeedsLayout()
                self.withLabel.setNeedsLayout()
                self.doorManLabel.setNeedsLayout()
                self.helloLabel.setNeedsLayout()
                self.firstnameLabel.setNeedsLayout()
                self.lastnameLabel.setNeedsLayout()
            }) { (completed) in
                // UI safety
                self.continueWithFacebookButton.hidden = false
                self.deviceIdTextField.hidden = true
                self.deviceIdHeaderText.hidden = true
                self.deviceIdFooterText.hidden = true
                self.deviceNameTextField.hidden = true
                self.pairButton.hidden = true
                self.gettingStartedLabel.hidden = false
                self.withLabel.hidden = false
                self.doorManLabel.hidden = false
                self.helloLabel.hidden = true
                self.firstnameLabel.hidden = true
                self.lastnameLabel.hidden = true
            }
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if(textField == deviceIdTextField){
            deviceNameTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            if(pairingTimer != nil) {
                pairingTimer.invalidate()
            }
            pairButtonClicked(textField)
        }
        return true
    }
    
    @IBAction func continueWithFacebookClicked(sender: AnyObject) {
        loginWithFacebook()
    }
    
    @IBAction func pairButtonClicked(sender: AnyObject) {
        dismissKeyboard()
        self.presentViewController(self.pairingAlert, animated: true, completion: self.sendPairRequest)
    }
    
    func sendPairRequest() {
        Alamofire.request(.POST,
            "https://www.mrttle.com/device/pair",
            parameters: [
                "fb_access_token": FBSDKAccessToken.currentAccessToken().tokenString,
                "did": deviceIdTextField.text!,
                "name": deviceNameTextField.text!
            ])
            .responseData { response in
                self.pairingAlert.dismissViewControllerAnimated(true, completion: nil)
                if response.result.isSuccess == true {
                    let statusCode = (response.response?.statusCode)!
                    if(statusCode == 201 || statusCode == 202) {
                        print("Device paired")
                        self.defaults.removeObjectForKey("LoginScene")
                        var device = [String: String]()
                        device["ID"] = self.deviceIdTextField.text!
                        device["name"] = self.deviceNameTextField.text!
                        self.defaults.setObject(device, forKey: "Device")
                        NSNotificationCenter.defaultCenter().postNotificationName("Device", object: self, userInfo: device)
                        self.dismissViewControllerAnimated(true, completion: nil)
                    } else {
                        print("Cannot pair device: "+String(statusCode))
                        self.presentViewController(self.pairingFailedAlert, animated: true, completion: nil)
                    }
                } else {
                    print("Cannot pair device")
                    self.presentViewController(self.pairingFailedAlert, animated: true, completion: nil)
                }
        }
    }
    
    func getPairedDeviceCountTimeout(timer:NSTimer) {
        let userInfo = timer.userInfo as! String
        timer.invalidate()
        print("Refreshing pairing info")
        getPairedDeviceCount(userInfo)
    }
    
    func getPairedDeviceCount(access_token: String) {
        Alamofire.request(.GET,
            "https://www.mrttle.com/device/list",
            parameters: ["fb_access_token": FBSDKAccessToken.currentAccessToken().tokenString])
            .responseJSON { response in
                if(response.response?.statusCode == 401) {
                    // Login information is no longer valid
                    print("Cannot get device list, login information is invalid")
                    FBSDKLoginManager().logOut()
                    self.setScene(.Login, animated: true)
                }
                if response.result.isSuccess == true {
                    let result = response.result.value! as! NSDictionary
                    if(result["count"]!.intValue == 0){
                        print("User does not have device paired")
                        self.firstnameLabel.text = FBSDKProfile.currentProfile().firstName
                        self.lastnameLabel.text = FBSDKProfile.currentProfile().lastName
                        self.setScene(.Pair, animated: true)
                        self.pairingTimer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: #selector(self.getPairedDeviceCountTimeout(_:)), userInfo: access_token, repeats: false)
                    } else {
                        print("User have existing device, select device, dismiss the view")
                        self.defaults.removeObjectForKey("LoginScene")
                        let json = response.result.value as! NSDictionary
                        let devices = json["devices"] as! [NSDictionary]
                        var device = [String: String]()
                        // Never select any device
                        if(self.defaults.objectForKey("Device") == nil) {
                            // Select first device
                            device = devices[0] as! [String : String]
                        } else {
                            // Had select a device
                            // Check if the device is still available for selection
                            var found = false
                            for device in devices {
                                let d = self.defaults.objectForKey("Device")
                                let name = d!["name"]
                                if(device["name"]!.isEqual(name)) {
                                    found = true    // Available
                                    break
                                }
                            }
                            
                            // NA
                            if (!found) {
                                device = devices[0] as! [String : String]
                            }
                        }
                        print(device)
                        if(!device.isEmpty) {
                            self.defaults.setObject(device, forKey: "Device")
                            NSNotificationCenter.defaultCenter().postNotificationName("Device", object: self, userInfo: device)
                        }
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                }
        }
    }
    
    func loginWithFacebook() {
        print("Continue with Facebook")
        let readPermissions = ["public_profile", "email"]
        FBLoginManager.logInWithReadPermissions(readPermissions, fromViewController: self, handler: {
            (result:FBSDKLoginManagerLoginResult!, error:NSError!) -> Void in
            
            if (error != nil) {
                print("Process error")
                self.presentViewController(self.loginFailedAlert, animated: true, completion: nil)
            } else if (result.isCancelled) {
                print("Cancelled")
            } else {
                print("Logged in")
                
                FBSDKProfile.loadCurrentProfileWithCompletion({ (profile: FBSDKProfile!, error: NSError!) in
                    print("Updated current profile on the system")
                    print("  User name: "+profile.name)
                })
                
                if(result.grantedPermissions.contains("email")){
                    print("Permissions contain email")
                    self.fetchFBUserData()
                } else {
                    print("Permissions does NOT contain email")
                    self.presentViewController(self.needEmailAlert, animated: true, completion: nil)
                }
                
            }
        })
    }
    
    func fetchFBUserData() {
        if((FBSDKAccessToken.currentAccessToken()) != nil){
            let path = "me"
            let params = ["fields": "id,name,first_name,last_name,email"]
            let graphRequest = FBSDKGraphRequest(graphPath: path, parameters: params)
            
            graphRequest.startWithCompletionHandler({
                (connection:FBSDKGraphRequestConnection!, result:AnyObject!, error:NSError!) -> Void in
                print("Fetched user data from Facebook")
                if (error == nil) {
                    print(result)
                } else {
                    print(error)
                }
                print("Using user data to authenticate with the server")
                self.presentViewController(self.loadingAlert, animated: true, completion: self.loginWithServer)
                NSNotificationCenter.defaultCenter().postNotificationName("Login", object: self, userInfo: nil)
            })
        } else {
            print("Faied to fetched user data from Facebook")
            self.presentViewController(self.loginFailedAlert, animated: true, completion: nil)
        }
        
    }
    
    func loginWithServer() {
        Alamofire.request(.POST,
            "https://www.mrttle.com/auth/facebook/token",
            parameters: ["access_token": FBSDKAccessToken.currentAccessToken().tokenString])
            .responseData { response in
                self.loadingAlert.dismissViewControllerAnimated(true, completion: nil)
                if response.result.isSuccess == true {
                    let statusCode = (response.response?.statusCode)!
                    if(statusCode == 200) {
                        self.getPairedDeviceCount(FBSDKAccessToken.currentAccessToken().tokenString)
                    } else {
                        print("Login failed: " + String(statusCode))
                        FBSDKLoginManager().logOut()
                        self.presentViewController(self.loginFailedAlert, animated: true, completion: nil)
                    }
                } else {
                    print("Login failed")
                    FBSDKLoginManager().logOut()
                    self.presentViewController(self.loginFailedAlert, animated: true, completion: nil)
                }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
