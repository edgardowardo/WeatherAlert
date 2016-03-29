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
import TIPBadgeManager

extension AppDelegate : WatchSessionManagerDelegate {
    func buildApplicationContext() -> [String : AnyObject]? {
        guard let realm = try? Realm() else { return nil }
        let favourites = realm.objects(CurrentObject).filter("isFavourite == 1")
        func getForecasts(cityid : Int) -> [[String : AnyObject]] {
            let forecasts = realm.objects(ForecastObject).filter("cityid == \(cityid)").sorted("timefrom", ascending: true)
            return forecasts.map({ obj in return [ "timefrom" : obj.timefrom!, "directioncode" : obj.directioncode, "speedvalue" : obj.speedvalue, "speedname" : obj.speedname ] })
        }
        let context = favourites.map({ obj in return [ "cityid" : obj.cityid, "name" : obj.name, "speedvalue" : obj.speedvalue, "speedname" : obj.speedname, "directioncode" : obj.directioncode, "lastupdate" : obj.lastupdate!, "units" : obj.units.rawValue, "forecasts" : getForecasts(obj.cityid) ] })
        return ["favourites" : context]
    }
}

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
    
    func renumberBadgesOfPendingNotifications() {
        let app = UIApplication.sharedApplication()
        
        // clear the badge on the icon
        TIPBadgeManager.sharedInstance.clearAllBadgeValues(true)
        
        // first get a copy of all pending notifications (unfortunately you cannot 'modify' a pending notification)
        // if there are any pending notifications -> adjust their badge number
        if let pendings = app.scheduledLocalNotifications where pendings.count > 0 {
//print("renumberBadgesOfPendingNotifications: pendings.count(\(pendings.count)) ")

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
//print("renumberBadgesOfPendingNotifications: \(n.alertBody!) ")
            
            }
        }
    }
    
    func showCurrentObjectFromNotification(notification : NotificationObject) {
        if let current = realm.objects(CurrentObject).filter("cityid == \(notification.cityid)").first, container = self.window?.visibleViewController as? ContainerMenuViewController {
            notification.isNotificationRead = true
            if container.isLeftOpen() {
                container.closeLeft()
            }
            delegate.showCurrentObject(current)
        }
    }
    
    func handleNotification(notification : UILocalNotification, forApplication application : UIApplication) {
        NSLog("handleNotification: \(notification.alertBody!)")
        
        let a = UIAlertController(title: notification.alertTitle!, message: notification.alertBody!, preferredStyle: UIAlertControllerStyle.Alert)
        a.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
        
        if let notificationId = notification.userInfo?["notificationId"] as? String, notification = realm.objects(NotificationObject).filter("id == '\(notificationId)'").first {

            showCurrentObjectFromNotification(notification)
        }
        
        renumberBadgesOfPendingNotifications()
        self.window?.visibleViewController?.presentViewController(a, animated: true, completion: nil)
    }
    
    // MARK: - Application Delegates -
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        WatchSessionManager.sharedManager.delegate = self
        
        self.createMenuView()
        UIViewController.prepareInterstitialAds()
        
        if realm == nil {
            realm = try! Realm()
        }
        
        // observer to reset forecast notifications
        tokenFavourites = realm.objects(CurrentObject).addNotificationBlock { objects, error in
            //WatchSessionManager.sharedManager.updateApplicationContext(self.buildApplicationContext()!)
            NotificationObject.resetAlarm()
        }

        // load city on install
        if realm.objects(CityObject).count == 0 {
            CityObject.loadCityData()
        }
        
        if let o = launchOptions, notification = o[UIApplicationLaunchOptionsLocalNotificationKey] as? UILocalNotification {
            handleNotification(notification, forApplication: application)
        }
        
        return true
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
 
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        handleNotification(notification, forApplication: application)
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

