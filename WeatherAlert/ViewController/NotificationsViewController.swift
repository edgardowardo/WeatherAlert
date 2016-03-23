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
import TIPBadgeManager

class NotificationsViewController: UITableViewController{

    // MARK: - Properties -

    var realm : Realm! = nil
    var notifications : Results<(NotificationObject)>!
    
    // MARK: - View Controller Lifecycle -
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        TIPBadgeManager.sharedInstance.clearAllBadgeValues(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if realm == nil {
            realm = try! Realm()
        }
        notifications = realm.objects(NotificationObject).filter(NSPredicate(format: "fireDate < %@", NSDate())).sorted("fireDate", ascending: false)
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
        let n = notifications[indexPath.row]
        
        cell.contentView.backgroundColor = ( n.isNotificationRead ) ? UIColor.clearColor() : UIColor.flatCloudsColor()
        cell.textLabel?.font = UIFont(name: "HelveticaNeue-Thin", size: 17)
        cell.textLabel!.text = n.body
        cell.detailTextLabel!.text = "\(n.fireDate!.remainingTime)" // == \(n.fireDate!)"
        cell.imageView?.image = UIImage(named: "\(Direction(rawValue: n.directioncode)!.inverse.rawValue)-white")
        cell.imageView?.backgroundColor = Units.Metric.getColorOfSpeed(n.speedvalue)
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

