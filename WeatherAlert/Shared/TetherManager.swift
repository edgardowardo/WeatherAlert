//
//  TetherManager.swift
//  MatchCard
//
//  Created by EDGARDO AGNO on 19/01/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

/*
import Foundation
import WatchConnectivity

protocol TetherManagerDelegate {
    func didReceiveApplicationContext(context : [String : AnyObject])
}

@available(iOS 9.0, *)
class TetherManager : NSObject, WCSessionDelegate {
 
    // MARK:- Properties -
    
    let session: WCSession? = WCSession.isSupported() ? WCSession.defaultSession() : nil
    static let sharedInstance = TetherManager()
    var delegate : TetherManagerDelegate?
    
    // MARK:- Callbacks -
    
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        delegate?.didReceiveApplicationContext(applicationContext)
    }
    
    override init() {
        super.init()
        self.session?.delegate = self
        self.session?.activateSession()
    }
    
    deinit {
    }
} */
