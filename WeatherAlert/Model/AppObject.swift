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
    static let sharedInstance = AppObject.loadAppData()
    
    var units : Units {
        get {
            if let realm = try? Realm(), app = realm.objects(AppObject).first {
                return Units(rawValue: app._units)!
            }
            return Units(rawValue: Units.Metric.rawValue)!
        }
        set {
            if let realm = try? Realm() {
                try! realm.write {
                    if let app = AppObject.sharedInstance {
                        app._units = newValue.rawValue
                        realm.add(app, update: true)
                    }
                }
            }
        }
    }
    
    // MARK: - Type Functions -
    
    override static func primaryKey() -> String? {
        return "_id"
    }
    
    override static func ignoredProperties() -> [String] {
        return ["unit"]
    }
    
    static func loadAppData() -> AppObject? {
        var a : AppObject? = nil
        
        if let realm = try? Realm() {
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
        }
        return a
    }
}