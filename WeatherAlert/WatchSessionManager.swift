//
//  WatchSessionManager.swift
//  WeatherAlert
//
//  Created by EDGARDO AGNO on 27/03/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//


import WatchConnectivity

class WatchSessionManager : NSObject, WCSessionDelegate {
    
    // MARK:- Properties -
    
    static let sharedManager = WatchSessionManager()
    private lazy var session : WCSession? = {
        let sesh : WCSession? = WCSession.isSupported() ? WCSession.defaultSession() : nil
        if let s = sesh where s.paired && s.watchAppInstalled {
            return s
        }
        return nil
    }()
    
    // MARK:- Functions -
    
    internal func updateApplicationContext(context : [String : AnyObject]) throws {
        NSLog("updateApplicationContext - \(context)")
        try self.session?.updateApplicationContext(context)
    }

}
