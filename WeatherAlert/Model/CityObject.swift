//
//  CityEntity.swift
//  WeatherAlert
//
//  Created by EDGARDO AGNO on 19/02/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import RealmSwift

/*

 Notes :

 Why realm? It is the fastest local datastore! City search scans at least 200K records on disk. So performance is important.
 Why save city data on disk (loadCityData)? open weather map org recommends to query current data using city id to get unambiguous city result. This means storing city id's and name on disk

 Sample json to parse {"_id":3333164,"name":"City and Borough of Leeds","country":"GB","coord":{"lon":-1.5477,"lat":53.79644}}

 Search by name on the OpenWeather api is very ambiguous and does not return sensible results for example use Xxx returns a croatian city. It should return an error instead search locally is so much better!

 Cannot use RealmSearchViewController

*/

class CityObject: Object {
 
    // MARK: - Properties -
    
    dynamic var _id: Int = 0
    dynamic var name  = ""
    dynamic var country = ""
    dynamic var lon : Double = 0
    dynamic var lat : Double = 0
    
    // MARK: - Property Attributes -
    
    override static func primaryKey() -> String? {
        return "_id"
    }
    
    override static func indexedProperties() -> [String] {
        return ["name"]
    }
    
    // MARK: - Notifications -

    struct Notification {
        struct Identifier {
            static let willLoadCityData = "NotificationIdentifierOf_willLoadCityData"
            static let didLoadCityData = "NotificationIdentifierOf_didLoadCityData"
        }
    }
    
    // MARK: - Type Functions -
    
    static func loadCityData() {
        
        dispatch_async(dispatch_queue_create("loadCityOnBackground", nil)) { autoreleasepool {
            
            if let jsonFilePath = NSBundle.mainBundle().pathForResource("city.list", ofType: "json"), jsonData = NSData(contentsOfFile: jsonFilePath) {
                
                dispatch_sync(dispatch_get_main_queue(), {
                    NSNotificationCenter.defaultCenter().postNotificationName(Notification.Identifier.willLoadCityData, object: nil)
                })
                
                do {
                    let jsonObject = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions.MutableContainers)
                    
                    if let jsonArray = jsonObject as? [NSDictionary], realm = try? Realm() {
                        
                        realm.beginWrite()
                        
                        print("\(NSDate()) loadCityData")
                        
                        for cityData in jsonArray {
                            let city = CityObject()
                            
                            if let id = cityData["_id"] as? Int, name = cityData["name"] as? String, country = cityData["country"] as? String, coordData = cityData["coord"] as? [String : AnyObject], lon = coordData["lon"] as? Double, lat = coordData["lat"] as? Double {
                                    
                                city._id = id
                                city.name = name
                                city.country = country
                                city.lon = lon
                                city.lat = lat
                            }
                            
                            realm.add(city, update: true)
                        }
                        
                        try! realm.commitWrite()
                        
                        print("\(NSDate()) loadedCityData... \(realm.objects(CityObject).count) records")
                        print("Realm located at \(realm.path)")
                    }
                } catch {
                    print("city JSON Error: \(error)")
                }
                
                dispatch_sync(dispatch_get_main_queue(), {
                    NSNotificationCenter.defaultCenter().postNotificationName(Notification.Identifier.didLoadCityData, object: nil)
                })
            }
        }}
    }
}