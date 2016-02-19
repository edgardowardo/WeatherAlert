//
//  CitySearchViewController.swift
//  WeatherAlert
//
//  Created by EDGARDO AGNO on 19/02/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import UIKit
import RealmSwift
import ABFRealmSearchViewController

class CitySearchViewController: ABFRealmSearchViewController {
    
    let dateFormatter: NSDateFormatter = {
        let formatter = NSDateFormatter()
        formatter.dateStyle = NSDateFormatterStyle.ShortStyle
        
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.estimatedRowHeight = 88
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func searchViewController(searchViewController: ABFRealmSearchViewController, cellForObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = self.tableView.dequeueReusableCellWithIdentifier("CityCell")!
        
        if let city = anObject as? CityObject {
            
            cell.textLabel?.text = city.name

        }
        
        return cell
    }
    
    override func searchViewController(searchViewController: ABFRealmSearchViewController, didSelectObject selectedObject: AnyObject, atIndexPath indexPath: NSIndexPath) {

        searchViewController.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
//        if let city = anObject as? CityObject {
//            let webViewController = TOWebViewController(URLString: blog.urlString)
//            let navigationController = UINavigationController(rootViewController: webViewController)
//            self.presentViewController(navigationController, animated: true, completion: nil)
//        }
        
    }
}
