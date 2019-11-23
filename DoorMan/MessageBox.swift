//
//  MessageBox.swift
//  DoorMan
//
//  Created by Attawit Kittikrairit on 10/9/15.
//  Copyright © 2015 Attawit Kittikrairit. All rights reserved.
//

import UIKit

class MessageBox: UIView {
    
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
        layer.cornerRadius = 3;
        layer.masksToBounds = true;
    }

}
