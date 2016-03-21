//
//  ForecastObject.swift
//  WeatherAlert
//
//  Created by EDGARDO AGNO on 21/02/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import RealmSwift
import Fuzi

class ForecastObject: Object {
    
    // MARK: - Properties -
    
    dynamic var cityid: Int = 0
    dynamic var timefrom : NSDate? = nil
    dynamic var speedvalue : Double = 0
    dynamic var speedname = ""
    dynamic var directioncode = ""
    dynamic var directionname = ""
    dynamic var directionvalue : Double = 0
    dynamic var temperatureUnit = ""
    dynamic var temperatureValue = 0.0
    dynamic var id = NSUUID().UUIDString
    dynamic var notification : NotificationObject? = nil
    
    var isAlarmed : Bool {
        get {
            if let _ = notification {
                return true
            }
            return false
        }
    }
    
    // MARK: - Notifications -
    
    struct Notification {
        struct Identifier {
            static let didSaveForecastObjects = "NotificationIdentifierOf_didSaveForecastObjects"
        }
    }
    
    // MARK: - Property Attributes -
    
    override static func indexedProperties() -> [String] {
        return ["cityid", "timefrom"]
    }
    
    override static func ignoredProperties() -> [String] {
        return ["hour", "day", "date", "direction", "isAlarmed"]
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    var direction : Direction? {
        get {
            if directioncode.characters.count > 0 {
                return Direction(rawValue: directioncode)!
            } else {
                return nil
            }
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

    var date : NSDate? {
        get {
            if let t = timefrom {
                let cal = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
                let components = cal.components([.Day , .Month, .Year ], fromDate: t)
                let newDate = cal.dateFromComponents(components)
                return newDate
            }
            return nil
        }
    }

    
    // MARK: - Helpers -

    
    static func saveXML(xml : String, realm : Realm! = try! Realm()) {
        
        autoreleasepool {
            
            do {
                let document = try XMLDocument(string: xml)
                if let root = document.root {
                    
                    realm.beginWrite()
                    
                    var cityid = 0
                    
                    if let location = root.firstChild(tag:"location"), sublocation = location.firstChild(tag: "location"), id = sublocation["geobaseid"] {
                        cityid = Int(id)!
                    }
                    
                    //var allcount = realm.objects(ForecastObject).count
                    //print("\(NSDate()) saveXML() allForecasts(\(allcount))")

                    // Delete any existing forecasts
                    
                    for existing in realm.objects(ForecastObject).filter("cityid == \(cityid)") {
                        realm.delete(existing)
                    }
                    
                    if let forecasts = root.firstChild(tag : "forecast") {
                        for entry in forecasts.children {
                            guard entry.tag == "time" else { continue }
                            
                            let forecast = ForecastObject()
                            forecast.cityid = cityid
                            
                            if let timefrom = entry.attributes["from"] {
                                forecast.timefrom = NSDateFormatter.nsdateFromString(timefrom)
                            }
                            if let windDirection = entry.firstChild(tag: "windDirection"), dircode = windDirection["code"], dirname = windDirection["name"], dirvalue = windDirection["deg"] {
                                forecast.directioncode = dircode
                                forecast.directionname = dirname
                                forecast.directionvalue = NSString(string: dirvalue).doubleValue
                            }
                            if let windSpeed = entry.firstChild(tag: "windSpeed"), name = windSpeed["name"] {
                                forecast.speedname = name
                                if let val = windSpeed["mps"] {
                                    forecast.speedvalue = NSString(string: val).doubleValue
                                }
                                // TODO: find out tag name for imperial and metric!
                            }
                            if let temperature = entry.firstChild(tag: "temperature"), unit = temperature["unit"], val = temperature["value"] {
                                forecast.temperatureUnit = unit
                                forecast.temperatureValue = NSString(string: val).doubleValue
                            }
                            
                            realm.add(forecast, update: false)
                        }
                    }
                    
                    try! realm.commitWrite()
                    
                    //allcount = realm.objects(ForecastObject).count
                    //let savedlist = realm.objects(ForecastObject).filter("cityid == \(cityid)")
                    //print("\(NSDate()) savedXML(\(savedlist.count)) allForecasts(\(allcount))")
                    //print("Realm located at \(realm.path)")
                    
                    NSNotificationCenter.defaultCenter().postNotificationName(Notification.Identifier.didSaveForecastObjects, object: cityid)
                }
                
            } catch let error {
                print(error)
            }
        }
    }
}