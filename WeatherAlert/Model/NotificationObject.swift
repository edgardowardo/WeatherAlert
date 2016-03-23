//
//  NotificationObject.swift
//  WeatherAlert
//
//  Created by EDGARDO AGNO on 20/03/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import RealmSwift

class NotificationObject: Object {
    
    // MARK: - Properties -

    dynamic var cityid: Int = 0
    dynamic var speedvalue : Double = 0
    dynamic var directioncode = ""
    dynamic var body = ""
    dynamic var fireDate : NSDate? = nil
    dynamic var id = NSUUID().UUIDString
    dynamic var _isNotificationRead : Bool = false
    
    var isNotificationRead : Bool {
        get {
            return self._isNotificationRead
        }
        set {
            if let _ = self.realm {
                try! realm!.write {
                    self._isNotificationRead = newValue
                    realm!.add(self, update: true)
                }
            }
        }
    }
    
    // MARK: - Functions -
    
    override static func ignoredProperties() -> [String] {
        return ["isNotificationRead"]
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    convenience init(cityid : Int, speedvalue : Double, directioncode : String, body: String, fireDate : NSDate?, forecast: ForecastObject) {
        self.init()
        self.cityid = cityid
        self.speedvalue = speedvalue
        self.directioncode = directioncode
        self.body = body
        self.fireDate = fireDate
        forecast.notification = self
    }
    
    static func resetAlarm() {
        guard let realm = try? Realm() else { return }
        
        let application = UIApplication.sharedApplication()
        application.cancelAllLocalNotifications()
        application.applicationIconBadgeNumber = 0
//
        print("resetAlarm: cancelAllLocalNotifications")
        
        let currents = realm.objects(CurrentObject).filter("isFavourite == 1")
        if currents.count == 0 {
            return
        }
        
        guard let app = AppObject.sharedInstance where app.allowNotifications else { return }
        
        let directions = app.oppositeCodes
        let max : Double
        if app.speedMax == app.units.maxSpeed {
            max = 1000.0 // predicates do not like Double.infinity
        }  else {
            max = app.speedMax
        }
        
        var interv = 0.0
        let cityids = currents.map({ "\($0.cityid)" }).joinWithSeparator(",")
        let forecasts = realm.objects(ForecastObject).filter("cityid IN {\(cityids)} ").sorted("timefrom", ascending: true)
//
        print("resetAlarm: forecasts.count(\(forecasts.count)) ")
        
        
        realm.beginWrite()
        
        for f in forecasts {
            if let _ = f.direction, _ = directions.filter({ $0 == f.directioncode }).first, timefrom = f.timefrom, c = realm.objects(CurrentObject).filter("cityid == \(f.cityid)").first where NSDate().compare(timefrom) == .OrderedAscending && app.speedMin ... max ~= f.speedvalue {
                
                let speedname : String = ( f.speedname.characters.count == 0 ) ? "Windless" : f.speedname
                let body = "\(speedname) (\(f.speedvalue) \(c.units.speed)) at \(c.name) coming from \(f.directionname.lowercaseString)."
                interv = interv + 60
                let fireDate = NSDate(timeIntervalSinceNow: interv) //f.timefrom
                
                // create the persistent notification object
                var n : NotificationObject
                if let note = f.notification {
                    n = note
                } else {
                    n = NotificationObject(cityid: f.cityid, speedvalue: f.speedvalue, directioncode: f.directioncode, body: body, fireDate: fireDate, forecast: f)
                }
                n.body = body
                n.fireDate = fireDate
                n._isNotificationRead = false
                realm.add(n, update: true)
                
                // create the iOS local notificatin object
                let notification = UILocalNotification()
                notification.timeZone = NSTimeZone.defaultTimeZone()
                notification.fireDate = fireDate
                notification.alertAction = "Show details"
                notification.alertTitle = "Wind Times"
                notification.alertBody = body
                notification.soundName = UILocalNotificationDefaultSoundName
                notification.applicationIconBadgeNumber = application.scheduledLocalNotifications!.count + 1
                notification.userInfo = ["cityid" : c.cityid, "timefrom" : f.timefrom!, "notificationId" : n.id]
                application.scheduleLocalNotification(notification)
//
                print("resetAlarm: \(notification.alertBody!) \(fireDate)")
            } else {
                f.notification = nil
            }
        }
        
        try! realm.commitWrite()        
    }
}