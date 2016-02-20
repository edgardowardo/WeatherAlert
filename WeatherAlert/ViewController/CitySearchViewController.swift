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
import Alamofire

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
        
        if let city = anObject as? CityObject {
            
            print("\(city._id)")
            
            let baseURLString = "http://api.openweathermap.org/data/2.5/weather?"
            let appid = "86514c2ae159c18ed4c1908defe97b2d"
            
            Alamofire.request(.GET, baseURLString, parameters: ["id": "\(city._id)", "APPID" : appid])
                .responseJSON { response in
                    print("request == \(response.request!)")  // original URL request
                    print("response == \(response.response)" ) // URL response
                    print("data == \(response.data)")     // server data
                    print("result == \(response.result)")   // result of response serialization
                    
                    if let JSON = response.result.value {
                        print("JSON: \(JSON)")
                    }
            }
        }
    }
}
