//
//  CurrentObject.swift
//  WeatherAlert
//
//  Created by EDGARDO AGNO on 20/02/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import RealmSwift
import Fuzi

class CurrentObject: Object {
    
    // MARK: - Properties -
    
    dynamic var cityid: Int = 0
    dynamic var name  = ""
    dynamic var country = ""
    dynamic var lon : Double = 0
    dynamic var lat : Double = 0
    dynamic var speedvalue : Double = 0
    dynamic var speedname = ""
    dynamic var directioncode = ""
    dynamic var directionname = ""
    dynamic var directionvalue : Double = 0
    dynamic var lastupdate : NSDate? = nil
    dynamic var isFavourite = false
    
    // MARK: - Notifications -
    
    struct Notification {
        struct Identifier {
            static let didSaveCurrentObject = "NotificationIdentifierOf_didSaveCurrentObject"
        }
    }
    
    // MARK: - Property Attributes -
    
    override static func primaryKey() -> String? {
        return "cityid"
    }
    
    override static func indexedProperties() -> [String] {
        return ["cityid"]
    }
    
    override static func ignoredProperties() -> [String] {
        return ["hourAndMin"]
    }
    
    var hourAndMin : String {
        get {
            if let t = lastupdate {
                let f = NSDateFormatter()
                f.dateFormat = "HH:ss"
                let s = f.stringFromDate(t)
                return s
            }
            return "sometime"
        }
    }
    
    // MARK: - Functions -
    
    func setPropertiesFromCity(city : CityObject) {
        cityid = city._id
        name = city.name
        country = city.country
        lon = city.lon
    }
    
    static func saveXML(xml : String) -> Int? {
        
        var cityid : Int? = nil
        
        autoreleasepool {
            
            do {
                let document = try XMLDocument(string: xml)
                if let root = document.root, realm = try? Realm() {
                    
                    realm.beginWrite()
                    //print("\(NSDate()) saveXML")

                    var current = CurrentObject()
                    
                    if let city = root.firstChild(tag:"city"), name = city["name"], id = city["id"], country = city.firstChild(tag: "country"), coord = city.firstChild(tag: "coord"), lon = coord["lon"], lat = coord["lat"] {
                        
                        if let existing = realm.objects(CurrentObject).filter("cityid == \(id)").first {
                            current = existing
                        } else {
                            current.cityid = Int(id)!
                        }
                        
                        current.name = name
                        current.country = country.stringValue
                        current.lon = NSString(string: lon).doubleValue
                        current.lat = NSString(string: lat).doubleValue
                    }
                    
                    if let wind = root.firstChild(tag:"wind"), speed = wind.firstChild(tag: "speed"), speedvalue = speed["value"], speedname = speed["name"], dir = wind.firstChild(tag: "direction"), dircode = dir["code"], dirname = dir["name"], dirvalue = dir["value"] {
                        
                        current.speedvalue = NSString(string: speedvalue).doubleValue
                        current.speedname = speedname
                        current.directioncode = dircode
                        current.directionname = dirname
                        current.directionvalue = NSString(string: dirvalue).doubleValue
                    }
                    
                    if let lastupdate = root.firstChild(tag : "lastupdate"), lastupdatevalue = lastupdate["value"] {
                        current.lastupdate = NSDateFormatter.nsdateFromString(lastupdatevalue)
                    }
                    
                    realm.add(current, update: true)

                    try! realm.commitWrite()
                    
                    //print("\(NSDate()) savedXML(\(current))")
                    //print("Realm located at \(realm.path)")
                    
                    NSNotificationCenter.defaultCenter().postNotificationName(Notification.Identifier.didSaveCurrentObject, object: current)
                    
                    cityid = current.cityid
                }
                
            } catch let error {
                print(error)
            }
        }
        
        return cityid
    }
}
