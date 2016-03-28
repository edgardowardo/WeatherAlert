//
//  WatchSessionManager.swift
//  WeatherAlert
//
//  Created by EDGARDO AGNO on 27/03/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import WatchConnectivity

@available(iOS 9.0, *)
class WatchSessionManager : NSObject, WCSessionDelegate {
    
    // MARK:- Properties -
    
    let session: WCSession? = WCSession.isSupported() ? WCSession.defaultSession() : nil
    static let sharedManager = WatchSessionManager()
    
    // MARK:- Functions -
    
    override init() {
        super.init()
        self.session?.delegate = self
        self.session?.activateSession()
    }
    
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        NSLog("didReceiveApplicationContext \(applicationContext)")
        
        dispatch_async(dispatch_get_main_queue()) { [weak self] in
            
//            self?.dataSourceChangedDelegates.forEach { $0.dataSourceDidUpdate(DataSource(data: applicationContext))}
        }
    }
}