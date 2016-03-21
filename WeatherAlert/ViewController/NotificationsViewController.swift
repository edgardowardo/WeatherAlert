//
//  FirstViewController.swift
//  TabbedApp
//
//  Created by EDGARDO AGNO on 21/03/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class NotificationsViewController: UITableViewController{

    // MARK: - Properties -

    var realm : Realm! = nil
    var token : RLMNotificationToken!
    var notifications : Results<(NotificationObject)>!
    

    // MARK: - Functions -
    
    func updateTabBadge() {
        
        let filteredNotifications = notifications.filter("_isNotificationRead == 0")
        if filteredNotifications.count > 0 {
            self.tabBarItem.badgeValue = "\(notifications.count)"
        } else {
            self.tabBarItem.badgeValue = nil
        }
    }
    
    // MARK: - View Controller Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if realm == nil {
            realm = try! Realm()
        }
        token = realm.objects(NotificationObject).addNotificationBlock { notifications, realm in
            self.notifications = notifications!.filter(NSPredicate(format: "fireDate < %@", NSDate())).sorted("fireDate", ascending: false)
            self.updateTabBadge()
            self.tableView.reloadData()
        }
        
        notifications = realm.objects(NotificationObject).filter(NSPredicate(format: "fireDate < %@", NSDate())).sorted("fireDate", ascending: false)
        updateTabBadge()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table View -
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("NotificationCell", forIndexPath: indexPath)
        let c = notifications[indexPath.row]
        
        cell.contentView.backgroundColor = ( c.isNotificationRead ) ? UIColor.clearColor() : UIColor.flatCloudsColor()
        cell.textLabel?.font = UIFont(name: "HelveticaNeue-Thin", size: 17)
        cell.textLabel!.text = c.body
        cell.detailTextLabel!.text = "\(c.fireDate!.remainingTime)" // == \(c.fireDate!)"
        cell.imageView?.image = UIImage(named: "\(Direction(rawValue: c.forecast.directioncode)!.inverse.rawValue)-white")
        cell.imageView?.backgroundColor = Units.Metric.getColorOfSpeed(c.forecast.speedvalue)
        cell.imageView?.layer.cornerRadius = cell.imageView!.frame.size.width / 2
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let n = notifications[indexPath.row]
        if !n.isNotificationRead {
            n.isNotificationRead = true
        }
        
        //showCurrentObject(current)
        
    }
}

