//
//  NSDate.swift
//  WeatherAlert
//
//  Created by EDGARDO AGNO on 21/02/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import Foundation

extension NSDate {
    func isYesterday() -> Bool {
        let cal = NSCalendar.currentCalendar()
        let yesterdayAndTime = cal.dateByAddingUnit(.Day, value: -1, toDate: NSDate(), options: [])!
        var components = cal.components([.Era, .Year, .Month, .Day], fromDate:yesterdayAndTime)
        let yesterday = cal.dateFromComponents(components)!
        
        components = cal.components([.Era, .Year, .Month, .Day], fromDate:self)
        let otherDate = cal.dateFromComponents(components)!
        
        if(yesterday.isEqualToDate(otherDate)) {
            return true
        } else {
            return false
        }
    }    
    
    func isToday() -> Bool {
        let cal = NSCalendar.currentCalendar()
        var components = cal.components([.Era, .Year, .Month, .Day], fromDate:NSDate())
        let today = cal.dateFromComponents(components)!
        
        components = cal.components([.Era, .Year, .Month, .Day], fromDate:self)
        let otherDate = cal.dateFromComponents(components)!
        
        if(today.isEqualToDate(otherDate)) {
            return true
        } else {
            return false
        }
    }
    
    var text: String {
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en_UK")
        formatter.dateFormat = "dd-MMM-yyyy HH:mm"
        return formatter.stringFromDate(self)
    }
    
    var hoursIntervalForSearch : Double {
        return 2.0
    }
    
    var hourAndMin : String {
        let t = self
        let f = NSDateFormatter()
        f.dateFormat = "HH:mm"
        let s = f.stringFromDate(t)
        return s
    }
    
    var remainingTime : String {
        let unitFlags: NSCalendarUnit = [.Minute, .Hour, .Day, .Month, .Year]
        let c = NSCalendar.currentCalendar().components(unitFlags, fromDate: self, toDate: NSDate(), options: [])
        var remaining : String?
        
        // If it's been years return this
        if c.year > 0 {
            remaining = "\(c.year) year"
        }
        if let r = remaining where c.year > 1 {
            remaining = "\(r)s"
        }
        if let years = remaining {
            return "\(years) ago"
        }
        
        // If it's been months return this
        if c.month > 0 {
            remaining = "\(c.month) month"
        }
        if let r = remaining where c.month > 1 {
            remaining = "\(r)s"
        }
        if let months = remaining {
            return "\(months) ago"
        }
        
        // If it's been days return this
        if c.day > 0 {
            remaining = "\(c.day) day"
        }
        if let r = remaining where c.day > 1 {
            remaining = "\(r)s"
        }
        if let day = remaining {
            return "\(day) ago"
        }
        
        
        // If it's been hours return this
        if c.hour > 0 {
            remaining = "\(c.hour) hour"
        }
        if let r = remaining where c.hour > 1 {
            remaining = "\(r)s"
        }
        if let hour = remaining {
            return "\(hour) ago"
        }
        
        
        // If it's been minutes return this
        if c.minute > 0 {
            remaining = "\(c.minute) minute"
        }
        if let r = remaining where c.minute > 1 {
            remaining = "\(r)s"
        }
        if let minute = remaining {
            return "\(minute) ago"
        }
        
        return "now"
    }
}

extension NSDateFormatter {
    static func openweatherFormat() -> String {
        return "yyyy-MM-dd'T'HH:mm:ss"
    }
    static func nsdateFromString(string : String) -> NSDate? {
        let formatter = NSDateFormatter()
        formatter.locale = NSLocale(localeIdentifier: "en_UK")
        formatter.dateFormat = NSDateFormatter.openweatherFormat()
        
        guard let date = formatter.dateFromString(string) else {
            assert(false, "no date from string")
            return nil
        }
        
        return date
    }
}