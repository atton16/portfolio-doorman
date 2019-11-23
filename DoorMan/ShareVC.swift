//
//  ShareVC.swift
//  DoorMan
//
//  Created by Attawit Kittikrairit on 6/21/16.
//  Copyright © 2016 Attawit Kittikrairit. All rights reserved.
//

import UIKit

class ShareVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var users: [String]!
    var tickets: [String]!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        users = ["Ae Kittikrairit", "Free Ticket"]
        tickets = ["1234-5678-9012","9876-5432-1098"]
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Share")!
        
        cell.textLabel?.text = users[indexPath.row]
        if(users[indexPath.row] == "Free Ticket") {
            cell.detailTextLabel?.text = tickets[indexPath.row]
        } else {
            cell.detailTextLabel?.text = ""
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("ShareToShareInfo", sender: self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
