//
//  CurrentObject.swift
//  WeatherAlert
//
//  Created by EDGARDO AGNO on 20/02/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import RealmSwift


class CurrentObject: Object {
    
    // MARK: - Properties -
    
    dynamic var _id: Int = 0
    dynamic var name  = ""
    dynamic var country = ""
    dynamic var lon : Float = 0
    dynamic var lat : Float = 0
    dynamic var windspeed : Double = 0
    dynamic var windname = ""
    dynamic var directioncode = ""
    dynamic var directionname = ""
    dynamic var directionvalue : Double = 0
    dynamic var lastupdate = NSDate()
    
    // MARK: - Property Attributes -
    
    override static func primaryKey() -> String? {
        return "_id"
    }
    
    override static func indexedProperties() -> [String] {
        return ["_id"]
    }
    
    static func saveXML(xml : String) {
        
    }
}
