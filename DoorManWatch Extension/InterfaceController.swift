//
//  InterfaceController.swift
//  DoorManWatch Extension
//
//  Created by Attawit Kittikrairit on 11/27/15.
//  Copyright © 2015 Attawit Kittikrairit. All rights reserved.
//

import WatchKit
import Foundation

let DEBUG = true

class InterfaceController: WKInterfaceController {
    @IBOutlet var unlockButton: WKInterfaceButton!
    
    var done = true
    var defaults: NSUserDefaults!

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        defaults = NSUserDefaults.init(suiteName: "DoorManShared")
        
        if(done) {
            unlockButton.setEnabled(true)
        }
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    @IBAction func unlockTrigger() {
        dispatch_async(dispatch_get_main_queue(), {
            print("start")
            self.done = false
            self.unlockButton.setEnabled(false)
            self.remoteUnlockTrigger()
        })
    }
    
    func remoteUnlockTrigger() {
        dispatch_async(dispatch_get_main_queue(), {
            let urlString = String(format: "http://safehouse71.hopto.org:44718/macros/unlockTrigger/")
            let req = NSMutableURLRequest(
                URL: NSURL(string: urlString)!,
                cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy,
                timeoutInterval: 5.0)
            req.HTTPMethod = "POST"

            let authStr = "everyone:safehouse71"
            let authData = authStr.dataUsingEncoding(NSASCIIStringEncoding)
            let authValue = String(format: "Basic %@", (authData?.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.EncodingEndLineWithLineFeed))!)
            req.setValue(authValue, forHTTPHeaderField: "Authorization")
            
            NSURLSession.sharedSession().dataTaskWithRequest(req, completionHandler: { data, response, error in
                if(error == nil) {
                    print("cleanup")
                    self.done = true
                    self.unlockButton.setEnabled(true)
                }
            }).resume()
        })
    }

}
