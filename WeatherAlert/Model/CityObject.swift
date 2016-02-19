//
//  CityEntity.swift
//  WeatherAlert
//
//  Created by EDGARDO AGNO on 19/02/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import RealmSwift

// Notes :
// Why realm? It is the fastest local datastore! City search scans at least 200K records on disk. So performance is important. 
// Why save city data on disk (loadCityData)? open weather map org recommends to query current data using city id to get unambiguous city result. This means storing city id's and name on disk

// Sample json to parse
// {"_id":3333164,"name":"City and Borough of Leeds","country":"GB","coord":{"lon":-1.5477,"lat":53.79644}}

class Coordinate : Object {
    dynamic var lon : Float = 0
    dynamic var lat : Float = 0
}

class CityObject: Object {
 
    // MARK: Properties
    dynamic var _id: Int = 0
    dynamic var name  = ""
    dynamic var country = ""
    dynamic var coord : Coordinate!
    
    // MARK: Property Attributes
    override static func primaryKey() -> String? {
        return "_id"
    }
    
    // MARK: Type Functions
    static func loadCityData() {
        if let jsonFilePath = NSBundle.mainBundle().pathForResource("city", ofType: "json"),
            jsonData = NSData(contentsOfFile: jsonFilePath) {
                
            do {
                let jsonObject = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers)
                
                if let jsonArray = jsonObject as? [NSDictionary], realm = try? Realm() {

                    realm.beginWrite()
                    
                    for cityData in jsonArray {
                        let city = CityObject()
                        
                        if let id = cityData["_id"] as? Int,
                            name = cityData["name"] as? String,
                            country = cityData["country"] as? String {
                                city._id = id
                                city.name = name
                                city.country = country
                        }
                        if let coordData = cityData["coord"] as? [String : AnyObject] {
                            city.coord = Coordinate()
                            if let lon = coordData["lon"] as? Float, lat = coordData["lat"] as? Float {
                                city.coord.lon = lon
                                city.coord.lat = lat
                            }
                        }
                        
                        realm.add(city, update: true)
                    }
                    
                    try! realm.commitWrite()
                }
            } catch {
                print("city JSON Error: \(error)")
            }
        }
    }
}