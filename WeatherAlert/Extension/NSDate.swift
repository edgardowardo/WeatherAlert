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