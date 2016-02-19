//
//  CitySearchViewController.swift
//  WeatherAlert
//
//  Created by EDGARDO AGNO on 19/02/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import UIKit
import RealmSwift
import RealmSearchViewController

class CitySearchViewController: RealmSearchViewController {
    
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let rightButton: UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: Selector("cancel"))
        navigationItem.rightBarButtonItem = rightButton;
    }
    
    func cancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func searchViewController(controller: RealmSearchViewController, cellForObject object: Object, atIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = self.tableView.dequeueReusableCellWithIdentifier("CityCell")!
        
        if let city = object as? CityObject {
            
            cell.textLabel?.text = "\(city.name), \(city.country)"

        }
        
        return cell
    }

    override func searchViewController(controller: RealmSearchViewController, didSelectObject anObject: Object, atIndexPath indexPath: NSIndexPath) {

        controller.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
//        if let city = anObject as? CityObject {
//            let webViewController = TOWebViewController(URLString: blog.urlString)
//            let navigationController = UINavigationController(rootViewController: webViewController)
//            self.presentViewController(navigationController, animated: true, completion: nil)
//        }
        
    }
}
