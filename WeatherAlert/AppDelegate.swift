//
//  AppDelegate.swift
//  WeatherAlert
//
//  Created by EDGARDO AGNO on 19/02/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import UIKit
import UIColor_FlatColors
import Realm
import RealmSwift
import iAd

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    // MARK: - Properties -
    
    var delegate : MapDelegate!
    var window: UIWindow?
    var realm : Realm! = nil
    var tokenFavourites : RLMNotificationToken!
    
    // MARK: - Helpers -
    
    private func createMenuView() {
        
        // create viewController code...
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainViewController = storyboard.instantiateViewControllerWithIdentifier("MainViewController") as! MainViewController
        let leftViewController = storyboard.instantiateViewControllerWithIdentifier("LeftViewController") as! LeftViewController
        let nvc: UINavigationController = UINavigationController(rootViewController: mainViewController)
        leftViewController.mainViewController = nvc
        
        let container = ContainerMenuViewController(mainViewController:nvc, leftMenuViewController: leftViewController)
        container.automaticallyAdjustsScrollViewInsets = true
        mainViewController.delegate = container
        self.delegate = mainViewController
        self.window?.backgroundColor = UIColor(red: 236.0, green: 238.0, blue: 241.0, alpha: 1.0)
        self.window?.rootViewController = container
        self.window?.makeKeyAndVisible()
        
        UIApplication.sharedApplication().statusBarStyle = .LightContent
        UISearchBar.appearance().barTintColor = UIColor.flatPeterRiverColor()
        UISearchBar.appearance().tintColor = UIColor.whiteColor()
        UILabel.appearanceWhenContainedInInstancesOfClasses([UITableViewHeaderFooterView.self]).font = UIFont(name: "HelveticaNeue-Light", size: 15)!
        UITextField.appearanceWhenContainedInInstancesOfClasses([UISearchBar.self]).tintColor = UIColor.flatPeterRiverColor()
        UINavigationBar.appearance().barTintColor = UIColor.flatPeterRiverColor()
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSFontAttributeName: UIFont(name: "HelveticaNeue-Light", size: 20)!, NSForegroundColorAttributeName : UIColor.whiteColor()]
        UITableViewHeaderFooterView.appearance().tintColor = UIColor.flatCloudsColor()
        
    }

    func resetAlarm() {

        let application = UIApplication.sharedApplication()
        application.cancelAllLocalNotifications()
        application.applicationIconBadgeNumber = 0
//        print("cancelAllLocalNotifications")
        
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
        let forecasts = self.realm.objects(ForecastObject).filter("cityid IN {\(cityids)} ").filter("speedvalue BETWEEN {\(app.speedMin),\(max)} ").filter("directioncode IN { \(directions) }").sorted("timefrom", ascending: true)
//print("resetAlarm: forecasts.count(\(forecasts.count)) ")
        for f in forecasts {
            if let _ = f.direction, timefrom = f.timefrom, c = realm.objects(CurrentObject).filter("cityid == \(f.cityid)").first where NSDate().compare(timefrom) == .OrderedAscending {
                let notification = UILocalNotification()
                let speedname : String = ( f.speedname.characters.count == 0 ) ? "Windless" : f.speedname
                notification.timeZone = NSTimeZone.defaultTimeZone()
                notification.fireDate = f.timefrom
                interv = interv + 60
//                notification.fireDate = NSDate(timeIntervalSinceNow: interv)
                notification.alertAction = "show details"
                notification.alertTitle = "Wind Times"
                notification.alertBody = "\(speedname) (\(f.speedvalue) \(c.units.speed)) in \(c.name) coming from \(f.directionname.lowercaseString). Forecast on \(c.lastupdate!.text)."
                notification.soundName = UILocalNotificationDefaultSoundName
                notification.applicationIconBadgeNumber = application.scheduledLocalNotifications!.count + 1
                notification.userInfo = ["cityid" : c.cityid]
                application.scheduleLocalNotification(notification)
//print("resetAlarm: \(notification.alertBody!) \(f.timefrom!) ")
            }
        }
    }
    
    func renumberBadgesOfPendingNotifications() {
        let app = UIApplication.sharedApplication()
        
        // clear the badge on the icon
        app.applicationIconBadgeNumber = 0
        
        // first get a copy of all pending notifications (unfortunately you cannot 'modify' a pending notification)
        // if there are any pending notifications -> adjust their badge number
        if let pendings = app.scheduledLocalNotifications where pendings.count > 0 {
//            print("renumberBadgesOfPendingNotifications: pendings.count(\(pendings.count)) ")

            // sorted by fire date.
            let notifications = pendings.sort({ p1, p2 in p1.fireDate!.compare(p2.fireDate!) == .OrderedAscending })
            
            // clear all pending notifications
            app.cancelAllLocalNotifications()
            
            // the for loop will 'restore' the pending notifications, but with corrected badge numbers
            var badgeNumber = 1
            for n in notifications {
                
                // modify the badgeNumber
                n.applicationIconBadgeNumber = badgeNumber++
                
                // schedule 'again'
                app.scheduleLocalNotification(n)
//                print("renumberBadgesOfPendingNotifications: \(n.alertBody!) ")
            
            }
        }
    }
    
    // MARK: - Application Delegates -
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        self.createMenuView()
        UIViewController.prepareInterstitialAds()
        
        if realm == nil {
            realm = try! Realm()
        }
        
        // observer to reset forecast notifications
        tokenFavourites = realm.objects(CurrentObject).filter("isFavourite == 1").addNotificationBlock { objects, error in
            self.resetAlarm()
        }

        // load city on install
        if realm.objects(CityObject).count == 0 {
            CityObject.loadCityData()
        }
        
        if let o = launchOptions, notification = o[UIApplicationLaunchOptionsLocalNotificationKey] as? UILocalNotification {
            self.application(application, didReceiveLocalNotification: notification)
        }
        
        return true
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
 
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        let a = UIAlertController(title: notification.alertTitle!, message: notification.alertBody!, preferredStyle: UIAlertControllerStyle.Alert)
        a.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
        if let cityid = notification.userInfo?["cityid"] as? Int, current = realm.objects(CurrentObject).filter("cityid == \(cityid)").first, container = self.window?.visibleViewController as? ContainerMenuViewController {
            if container.isLeftOpen() {
                container.closeLeft()
            }
            delegate.showCurrentObject(current)
        }
        renumberBadgesOfPendingNotifications()
        self.window?.visibleViewController?.presentViewController(a, animated: true, completion: nil)
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

