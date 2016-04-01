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

    var data : DataSource? = nil
    let session: WCSession? = WCSession.isSupported() ? WCSession.defaultSession() : nil
    static let sharedManager = WatchSessionManager()
    private var dataSourceChangedDelegates = [DataSourceChangedDelegate]()
    
    var isStale : Bool {
        if let d = data {
            return d.isStale
        }
        return true
    }
    
    // MARK:- Functions -
    
    override init() {
        super.init()
        self.session?.delegate = self
        self.session?.activateSession()
    }
    
    func addDataSourceChangedDelegate<T where T: DataSourceChangedDelegate, T: Equatable>(delegate: T) {
        dataSourceChangedDelegates.append(delegate)
    }
    
    func removeDataSourceChangedDelegate<T where T: DataSourceChangedDelegate, T: Equatable>(delegate: T) {
        for (index, dataSourceDelegate) in dataSourceChangedDelegates.enumerate() {
            if let dataSourceDelegate = dataSourceDelegate as? T where dataSourceDelegate == delegate {
                dataSourceChangedDelegates.removeAtIndex(index)
                break
            }
        }
    }
    
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        NSLog("log-didReceiveApplicationContext \(applicationContext)")
        dispatch_async(dispatch_get_main_queue()) { [weak self] in
            self?.data = DataSource(data: applicationContext)
            guard let data = self?.data else { return }
            self?.dataSourceChangedDelegates.forEach { $0.dataSourceDidUpdate(data)}
        }
    }
}