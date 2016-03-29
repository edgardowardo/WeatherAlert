//
//  DataSource.swift
//  WeatherAlert
//
//  Created by EDGARDO AGNO on 28/03/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import Foundation

protocol DataSourceChangedDelegate {

    func dataSourceDidUpdate(dataSource: DataSource)

}
struct DataSource {
    
    let currentObjects : [CurrentObject]?
    
    init(data: [String : AnyObject]) {
        if let favouritesData = data["favourites"] as? [[String : AnyObject]] {
             currentObjects = favouritesData.map({ return CurrentObject(data: $0)  })
        } else {
            currentObjects = nil
        }
    }
}

class CurrentObject {
    var cityid: Int = 0
    var directioncode = ""
    var lastupdate : NSDate? = nil
    var name  = ""
    var speedname = ""
    var speedvalue : Double = 0
    
    init(data : [String : AnyObject]) {
        if let cityid = data["cityid"] as? Int, name = data["name"] as? String {
            self.cityid = cityid
            self.name = name
        }
        if let directioncode = data["directioncode"] as? String {
            self.directioncode = directioncode
        }
        if let speedvalue = data["speedvalue"] as? Double, speedname = data["speedname"] as? String {
            self.speedvalue = speedvalue
            self.speedname = speedname
        }
        if let lastupdate = data["lastupdate"] as? NSDate {
            self.lastupdate = lastupdate
        }
    }
}