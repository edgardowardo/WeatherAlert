//
//  WatchSessionManager.swift
//  WeatherAlert
//
//  Created by EDGARDO AGNO on 27/03/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import WatchConnectivity

protocol WatchSessionManagerDelegate {
    func buildApplicationContext() -> [String : AnyObject]?
}

@available(iOS 9.0, *)
class WatchSessionManager : NSObject, WCSessionDelegate {
    
    // MARK:- Properties -
    
    static let sharedManager = WatchSessionManager()
    var delegate : WatchSessionManagerDelegate?
    let session: WCSession? = WCSession.isSupported() ? WCSession.defaultSession() : nil
    
    // MARK:- Functions -
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        if let key = message["command"] as? String, context = delegate?.buildApplicationContext()  where key == "getFavourites" {
            replyHandler(["reply" : "willSendApplicationContext"])
            updateApplicationContext(context)
        }
    }
    
    func updateApplicationContext(context : [String : AnyObject]) {
        NSLog("updateApplicationContext - \(context)")
        guard let session = self.session where session.paired && session.watchAppInstalled else { return }
        try! session.updateApplicationContext(context)
    }
    
    override init() {
        super.init()
        self.session?.delegate = self
        self.session?.activateSession()
    }
}