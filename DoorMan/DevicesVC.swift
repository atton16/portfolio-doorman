//
//  DevicesVC.swift
//  DoorMan
//
//  Created by Attawit Kittikrairit on 6/16/16.
//  Copyright © 2016 Attawit Kittikrairit. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Alamofire

class DevicesVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var tableView: UITableView!
    var devices: [NSDictionary]!
    var defaults: NSUserDefaults!
    var loadingAlert: UIAlertController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        devices = [NSDictionary]()
        defaults = NSUserDefaults.init(suiteName: "DoorManShared")
        
        // Create loadingAlert
        loadingAlert = UIAlertController(title: nil, message: "Refreshing\n\n", preferredStyle: UIAlertControllerStyle.Alert)
        let indicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
        indicator.center = CGPointMake(135.0, 65.5)
        indicator.color = UIColor.blackColor()
        indicator.startAnimating()
        loadingAlert.view.addSubview(indicator)
        
        // Populate Devices
        presentViewController(loadingAlert, animated: true, completion: populateDevices)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        //Using "Device"
        let cell = tableView.dequeueReusableCellWithIdentifier("Device", forIndexPath: indexPath)
        cell.textLabel?.text = (devices[indexPath.row]["name"] as! String)
        
        let label = UILabel(frame: CGRectMake(0,0,36,36))
        label.text = (devices[indexPath.row]["name"] as! NSString).substringToIndex(1)
        label.font = UIFont.boldSystemFontOfSize(20)
        label.textColor = UIColor.whiteColor()
        label.textAlignment = .Center;
        label.backgroundColor = UIColor.lightGrayColor()
        label.layer.masksToBounds = true
        label.layer.cornerRadius = label.frame.size.height / 2.0
        // Make it an image
        UIGraphicsBeginImageContextWithOptions(label.bounds.size, false, 0.0)
        label.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Put it in the cell
        cell.imageView!.image = img
        
        // Add Separator
        let x = cell.textLabel!.frame.origin.x + 36 + 15
        let y = cell.frame.height - 1
        let width = cell.frame.width - x
        let height = 1 as CGFloat
        let frame = CGRectMake(x, y, width, height)
        let separator = UIView(frame: frame)
        separator.backgroundColor = UIColor(white: 231/255, alpha: 1)
        cell.contentView.addSubview(separator)
        
        return cell
    }
    
    func populateDevices() {
        Alamofire.request(.GET,
            "https://www.mrttle.com/device/list",
            parameters: [
                "fb_access_token": FBSDKAccessToken.currentAccessToken().tokenString
            ])
            .responseJSON { response in
                if response.result.isSuccess == true {
                    let statusCode = (response.response?.statusCode)!
                    if(statusCode == 200) {
                        print("Retrieved devices")
                        let json = response.result.value as! NSDictionary
                        self.devices = json["devices"] as! [NSDictionary]
                        self.tableView.reloadData()
                        print(json)
                    } else if (statusCode == 401) {
                        print("Cannot retrieve device list, unauthorized")
                    } else {
                        print("Cannot retrieve device list: "+String(statusCode))
                    }
                }
                self.loadingAlert.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("Row selected: " + String(indexPath.row))
        let device = devices[indexPath.row] as! [String : String]
        defaults.setObject(device, forKey: "Device")
        NSNotificationCenter.defaultCenter().postNotificationName("Device", object: self, userInfo: device)
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
