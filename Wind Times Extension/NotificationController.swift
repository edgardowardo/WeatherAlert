//
//  NotificationController.swift
//  Wind Times Extension
//
//  Created by EDGARDO AGNO on 25/03/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import WatchKit
import Foundation


class NotificationController: WKUserNotificationInterfaceController {

    @IBOutlet var groupDirection: WKInterfaceGroup!
    @IBOutlet var imageDirection: WKInterfaceImage!
    @IBOutlet var labelBody: WKInterfaceLabel!
    
    override init() {
        // Initialize variables here.
        super.init()
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    
    override func didReceiveLocalNotification(localNotification: UILocalNotification, withCompletion completionHandler: ((WKUserNotificationInterfaceType) -> Void)) {
        // This method is called when a local notification needs to be presented.
        // Implement it if you use a dynamic notification interface.
        // Populate your dynamic notification interface as quickly as possible.
        //
        // After populating your dynamic notification interface call the completion block.
        
        labelBody.setText(localNotification.alertBody)
        
        if let userInfo = localNotification.userInfo {
            if let speedvalue = userInfo["speedvalue"] as? Double, units = userInfo["units"] as? String, unit = Units(rawValue: units) {
                groupDirection.setBackgroundColor(unit.getColorOfSpeed(speedvalue))
            }
            if let directioncode = userInfo["directioncode"] as? String, d = Direction(rawValue: directioncode) {
                imageDirection.setImageNamed("\(d.inverse.rawValue)-white")
            }
        }
        
        completionHandler(.Custom)
    }
    
    
    /*
    override func didReceiveRemoteNotification(remoteNotification: [NSObject : AnyObject], withCompletion completionHandler: ((WKUserNotificationInterfaceType) -> Void)) {
        // This method is called when a remote notification needs to be presented.
        // Implement it if you use a dynamic notification interface.
        // Populate your dynamic notification interface as quickly as possible.
        //
        // After populating your dynamic notification interface call the completion block.
        completionHandler(.Custom)
    }
    */
}
