//
//  AppObject.swift
//  WeatherAlert
//
//  Created by EDGARDO AGNO on 29/02/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import RealmSwift

class AppObject: Object {
    
    // MARK: - Properties -
    
    dynamic var _id = "1"
    dynamic var _units : String = Units.Metric.rawValue
    dynamic var _sortProperty = "lastupdate"
    dynamic var distanceKm = 2.0
    dynamic var _isAdsShown = true
    dynamic var _speedMin = 15.0
    dynamic var _speedMax = 17.0
    dynamic var _directionCodeStart = "N"
    dynamic var _directionCodeEnd = "NE"
    dynamic var _maxNotifications = 1 // per city
    
    static var sharedInstance = AppObject.loadAppData()
    
    var isAdsShown : Bool {
        get {
            if let _ = self.realm, app = realm!.objects(AppObject).first {
                return app._isAdsShown
            }
            return true
        }
        set {
            if let _ = self.realm {
                try! realm!.write {
                    if let app = AppObject.sharedInstance {
                        app._isAdsShown = newValue
                        realm!.add(app, update: true)
                    }
                }
            }
        }
    }
    
    // km/s
    var speedMin : Double {
        get {
            return _speedMin
        }
        set {
            if let _ = realm {
                try! realm!.write {
                    _speedMin = newValue
                    realm!.add(self, update: true)
                }
            }
        }
    }
    
    // km/s
    var speedMax : Double {
        get {
            return (_speedMax == units.maxSpeed) ? 999.0 : _speedMax
        }
        set {
            if let _ = realm {
                try! realm!.write {
                    _speedMax = newValue
                    realm!.add(self, update: true)
                }
            }
        }
    }
    
    var maxNotifications : Int {
        get {
            return (_maxNotifications == 10) ? 999 : _maxNotifications
        }
        set {
            if let _ = realm {
                try! realm!.write {
                    _maxNotifications = newValue
                    realm!.add(self, update: true)
                }
            }
        }
    }
    
    var directionCodeStart : String {
        get {
            return _directionCodeStart
        }
        set {
            if let _ = realm {
                try! realm!.write {
                    _directionCodeStart = newValue
                    realm!.add(self, update: true)
                }
            }
        }
    }

    var directionCodeEnd : String {
        get {
            return _directionCodeEnd
        }
        set {
            if let _ = realm {
                try! realm!.write {
                    _directionCodeEnd = newValue
                    realm!.add(self, update: true)
                }
            }
        }
    }
    
    var units : Units {
        get {
            if let _ = self.realm, app = realm!.objects(AppObject).first {
                return Units(rawValue: app._units)!
            }
            return Units(rawValue: Units.Metric.rawValue)!
        }
        set {
            if let _ = self.realm {
                try! realm!.write {
                    if let app = AppObject.sharedInstance {
                        app._units = newValue.rawValue
                        realm!.add(app, update: true)
                    }
                }
            }
        }
    }
    
    var distance : Int {
        get {
            var d = Int(distanceKm)
            if units == .Imperial {
                d = Int(units.toImperial(distanceKm))
            }
            return d
        }
    }
    
    // MARK: - Type Functions -
    
    func getCodes(isInverse : Bool = false) -> [String] {
        var start = 0, end = 0
        var sliced = [String]()
        let directions = Direction.directions
        
        if isInverse {
            if let d = Direction(rawValue: directionCodeStart)?.inverse, indexStart = directions.indexOf(d) {
                start = indexStart
            }
            if let d = Direction(rawValue: directionCodeEnd)?.inverse, indexStart = directions.indexOf(d) {
                end = indexStart
            }
        } else {
            if let d = Direction(rawValue: directionCodeStart), indexStart = directions.indexOf(d) {
                start = indexStart
            }
            if let d = Direction(rawValue: directionCodeEnd), indexStart = directions.indexOf(d) {
                end = indexStart
            }
        }
        
        if start <= end {
            sliced = directions[start ... end].map({ "\($0.rawValue)"})
        } else {
            let half1 = directions[start ... directions.count - 1].map({ "\($0.rawValue)"})
            let half2 = directions[0 ... end].map({ "\($0.rawValue)"})
            let whole = half1 + half2
            sliced = whole
        }
        return sliced
    }
    
    override static func primaryKey() -> String? {
        return "_id"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["unit", "distance", "isAdsShown", "speedMin", "speedMax", "directionCodeStart", "directionCodeEnd", "maxNotifications"]
    }
    
    static func loadAppData(var realm : Realm! = nil) -> AppObject? {
        var a : AppObject? = nil
        
        if realm == nil {
            realm = try? Realm()
        }
        
        // If not existing, create it, else query the existing one
        if realm.objects(AppObject).count == 0 {
            try! realm.write {
                let app = AppObject()
                realm.add(app)
                a = app
            }
        } else {
            a = realm.objects(AppObject).first
        }
        
        return a
    }
}