//
//  DataSource.swift
//  WeatherAlert
//
//  Created by EDGARDO AGNO on 28/03/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import Foundation

protocol DataSourceChangedDelegate {

    func dataSourceDidUpdate(dataSource: DataSource)

}

struct DataSource {
    
    let currentObjects : [CurrentObject]?
    
    init(data: [String : AnyObject]) {
        if let favouritesData = data["favourites"] as? [[String : AnyObject]] {
             currentObjects = favouritesData.map({ return CurrentObject(data: $0)  })
        } else {
            currentObjects = nil
        }
    }
    
    var isStale : Bool {
        get {
            if let currents = currentObjects {
                if let _ = currents.filter({
                    let past = NSDate().timeIntervalSinceDate($0.lastupdate!) / 3600
                    NSLog("log-WatchSessionManager-past(\(past)), lastupdate=\($0.lastupdate)")
                    return past > NSDate().hoursIntervalForSearch
                }).first {
                    NSLog("log-WatchSessionManager.isStale(true): past limit")
                    return true
                }
                
                NSLog("log-WatchSessionManager.isStale(false): currentObjects are up-to-date")
                
                return false
            }
            NSLog("log-WatchSessionManager.isStale(true): currentObjects is nil therefore stale")
            
            return true
        }
    }
}


class ForecastObject {
    
    // MARK: - Properties -
    
    var timefrom : NSDate? = nil
    var direction : Direction? = nil
    var speedvalue : Double = 0
    var speedname = ""
    
    init(data : [String : AnyObject]) {
        if let timefrom = data["timefrom"] as? NSDate {
            self.timefrom = timefrom
        }
        if let directioncode = data["directioncode"] as? String {
            self.direction = Direction(rawValue: directioncode)
        }
        if let speedvalue = data["speedvalue"] as? Double, speedname = data["speedname"] as? String {
            self.speedvalue = speedvalue
            self.speedname = speedname
        }
    }
    
    var hour : String {
        get {
            if let t = timefrom {
                let h = NSCalendar.currentCalendar().component(.Hour, fromDate: t)
                let f = NSNumberFormatter()
                f.minimumIntegerDigits = 2
                return f.stringFromNumber(h)!
            }
            return "HH"
        }
    }
    
    var day : String {
        get {
            if let t = timefrom {
                if t.isToday() {
                    return "TODAY"
                } else if t.isYesterday() {
                    return ""
                }
                
                let f = NSDateFormatter()
                f.dateFormat = "EEE, dd MMM"
                let s = f.stringFromDate(t)
                return s.uppercaseString
            }
            return "TODAY"
        }
    }
    
}

class CurrentObject {
    
    // MARK: - Properties -
    
    var cityid: Int = 0
    var direction : Direction? = nil
    var lastupdate : NSDate? = nil
    var name  = ""
    var speedname = ""
    var speedvalue : Double = 0
    var units : Units = .Metric
    var forecasts = [ForecastObject]()
    
    init(data : [String : AnyObject]) {
        if let cityid = data["cityid"] as? Int, name = data["name"] as? String, units = data["units"] as? String {
            self.cityid = cityid
            self.name = name
            self.units = Units(rawValue: units)!
        }
        if let directioncode = data["directioncode"] as? String {
            self.direction = Direction(rawValue: directioncode)
        }
        if let speedvalue = data["speedvalue"] as? Double, speedname = data["speedname"] as? String {
            self.speedvalue = speedvalue
            self.speedname = speedname
        }
        if let lastupdate = data["lastupdate"] as? NSDate {
            self.lastupdate = lastupdate
        }
        if let forecasts = data["forecasts"] as? [[String : AnyObject]] {
            self.forecasts = forecasts.map({ return ForecastObject(data: $0) })
        }
    }
}