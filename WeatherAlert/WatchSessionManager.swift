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
        dispatch_async(dispatch_get_main_queue()) { [weak self] in
            NSLog("log-didReceiveMessage - \(message)")
            if let key = message["command"] as? String  where key == "getFavourites" {
                if let context = self?.delegate?.buildApplicationContext() {
                    replyHandler(["reply" : "willSendApplicationContext"])
                    self?.updateApplicationContext(context)
                } else {
                    replyHandler(["reply" : "willSendApplicationContextSoon"])
                }
            }
        }
    }
    
    func updateApplicationContext(context : [String : AnyObject]) {
        NSLog("log-updateApplicationContext - \(context)")
        guard let session = self.session where session.paired && session.watchAppInstalled else { return }
        try! session.updateApplicationContext(context)
    }
    
    override init() {
        super.init()
        self.session?.delegate = self
        self.session?.activateSession()
    }
}