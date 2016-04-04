//
//  CurrentObject.swift
//  WeatherAlert
//
//  Created by EDGARDO AGNO on 20/02/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import RealmSwift
import Fuzi
import CoreLocation
import MapKit

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
    dynamic var isComplicated = false
    dynamic var _units = ""
    
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
        return ["hourAndMin", "units", "location", "currentLocation", "distanceKm", "distanceText", "direction"]
    }
    
    var currentLocation : CLLocation?
    
    var direction : Direction? {
        get {
            if directioncode.characters.count > 0 {
                return Direction(rawValue: directioncode)!
            } else {
                return nil
            }
        }
    }
    
    var location : CLLocation {
        get {
            return CLLocation(latitude: self.lat, longitude: self.lon)
        }
    }
    
    var units : Units {
        get {
            return Units(rawValue: _units)!
        }
        set {
            _units = newValue.rawValue
        }
    }

    var distanceKm : Double {
        get {
            if let d = self.currentLocation?.distanceFromLocation(location) {
                let distance = d / 1000
                return distance
            }
            return 0.0
        }
    }
    
    var distanceText : String {
        get {
            if let _ = self.currentLocation {
                var units = Units.Metric
                var distance = self.distanceKm
                if let appUnits = AppObject.sharedInstance?.units where appUnits == .Imperial {
                    units = appUnits
                    distance = appUnits.toImperial(distance)
                }
                return ", \(distance.format(".0")) \(units.short)"
            }
            return ""
        }
    }
    
    // MARK: - Functions -
    
    func setPropertiesFromCity(city : CityObject, currentLocation : CLLocation? = nil) -> CurrentObject {
        cityid = city._id
        name = city.name
        country = city.country
        lon = city.lon
        lat = city.lat
        self.currentLocation = currentLocation
        return self
    }
    
    static func saveXML(xml : String, realm : Realm! = try! Realm()) -> Int? {
        
        var cityid : Int? = nil
        
        autoreleasepool {
            
            do {
                let document = try XMLDocument(string: xml)
                if let root = document.root {
                    
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
                    
                    if let u = AppObject.sharedInstance?.units {
                        current.units = u
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
                    
                    //NSLog("savedXML(\(current))")
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

extension CurrentObject : MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D {
        get {
            return self.location.coordinate
        }
    }
    
    var title: String? {
        get {
            return self.name
        }
    }

    var subtitle: String? {
        get {
            return self.country
        }
    }
}
