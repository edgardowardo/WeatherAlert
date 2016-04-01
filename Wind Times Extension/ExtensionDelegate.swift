//
//  ExtensionDelegate.swift
//  Wind Times Extension
//
//  Created by EDGARDO AGNO on 25/03/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import WatchKit

class ExtensionDelegate: NSObject, WKExtensionDelegate {

    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
        
        WatchSessionManager.sharedManager
        
        //NSLog("log-applicationDidFinishLaunching")
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        //NSLog("log-applicationDidBecomeActive")
        
        if WatchSessionManager.sharedManager.isStale {
            //NSLog("log-applicationDidBecomeActive.isStale(true)")
            
            WatchSessionManager.sharedManager.session?.sendMessage(["command" : "getFavourites"], replyHandler: { (data : [String : AnyObject]) -> Void in
                NSLog("log-replyHandler \(data)") }, errorHandler: nil)
        }
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, etc.
    }

}
