//
//  GlanceController.swift
//  DoorMan
//
//  Created by Attawit Kittikrairit on 11/27/15.
//  Copyright © 2015 Attawit Kittikrairit. All rights reserved.
//

import WatchKit
import Foundation


class GlanceController: WKInterfaceController {
    @IBOutlet var glanceImage: WKInterfaceImage!

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
//        let lockImg = UIImage(named: "Lock")
//        glanceImage.setImageNamed("Lock")
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
