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

    dynamic var forecast : ForecastObject? = nil
    dynamic var body = ""
    dynamic var fireDate : NSDate? = nil
    
    // MARK: - Functions -
    
    convenience init(forecast: ForecastObject) {
        self.init()
        self.forecast = forecast
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
        
        let directions = app.oppositeCodes.joinWithSeparator(",")
        let max : Double
        if app.speedMax == app.units.maxSpeed {
            max = 1000.0 // predicates do not like Double.infinity
        }  else {
            max = app.speedMax
        }
        
        var interv = 0.0
        let cityids = currents.map({ "\($0.cityid)" }).joinWithSeparator(",")
        let forecasts = realm.objects(ForecastObject).filter("cityid IN {\(cityids)} ").filter("speedvalue BETWEEN {\(app.speedMin),\(max)} ").filter("directioncode IN { \(directions) }").sorted("timefrom", ascending: true)
//
        print("resetAlarm: forecasts.count(\(forecasts.count)) ")
        
        realm.beginWrite()
        
        for f in forecasts {
            if let _ = f.direction, timefrom = f.timefrom, c = realm.objects(CurrentObject).filter("cityid == \(f.cityid)").first where NSDate().compare(timefrom) == .OrderedAscending {
                
                // create the iOS local notificatin object
                let notification = UILocalNotification()
                let speedname : String = ( f.speedname.characters.count == 0 ) ? "Windless" : f.speedname
                notification.timeZone = NSTimeZone.defaultTimeZone()
                notification.fireDate = f.timefrom
                interv = interv + 60
                notification.fireDate = NSDate(timeIntervalSinceNow: interv)
                notification.alertAction = "Show details"
                notification.alertTitle = "Wind Times"
                notification.alertBody = "\(speedname) (\(f.speedvalue) \(c.units.speed)) in \(c.name) coming from \(f.directionname.lowercaseString). Forecast on \(c.lastupdate!.text)."
                notification.soundName = UILocalNotificationDefaultSoundName
                notification.applicationIconBadgeNumber = application.scheduledLocalNotifications!.count + 1
                notification.userInfo = ["cityid" : c.cityid, "timefrom" : f.timefrom!]
                application.scheduleLocalNotification(notification)
//
                print("resetAlarm: \(notification.alertBody!) \(f.timefrom!) ")
                
                // create the persistent notification object
                let n = NotificationObject(forecast: f)
                n.body = notification.alertBody!
                n.fireDate = notification.fireDate
                realm.add(n)
            }
        }
        
        try! realm.commitWrite()        
    }
}