//
//  LeftMenuViewController.swift
//  WeatherAlert
//
//  Created by EDGARDO AGNO on 19/02/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import UIKit
import RealmSwift

class LeftViewController: UITableViewController {
    
    @IBAction func sliderChanged(sender: AnyObject) {
    }
    
    enum Items : Int {
        case Units = 0, Distance, Bin, License
    }
    
    var mainViewController: UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        cell.textLabel?.font = UIFont(name: "HelveticaNeue-Thin", size: 20)
        
        if let app = AppObject.sharedInstance where indexPath.row == Items.Units.rawValue {
            cell.textLabel?.text = "\(app.units) and °\(app.units.temperature)"
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        switch Items(rawValue: indexPath.row)! {
        // Units
        case .Units:
            if let app = AppObject.sharedInstance {
                let invert = app.units.inverse
                let a = UIAlertController(title: "Change units", message: "Would you like the next queries to return °\(invert.temperature) and \(invert.lowercase) measurements?", preferredStyle: UIAlertControllerStyle.Alert)
                a.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
                a.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.Default, handler: {(alert: UIAlertAction!) in
                    app.units = invert
                    self.tableView.reloadData()
                    NSNotificationCenter.defaultCenter().postNotificationName(CurrentObject.Notification.Identifier.didSaveCurrentObject, object: nil)
                }))
                UIApplication.delay(0.1, closure: { () -> () in
                    self.presentViewController(a, animated: true, completion: nil)
                })
            }
            
        // Clear recents
        case .Bin :
            let a = UIAlertController(title: "Clear recents", message: "Continue to clear recents?", preferredStyle: UIAlertControllerStyle.Alert)
            a.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
            a.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.Default, handler: {(alert: UIAlertAction!) in
                if let realm = try? Realm() {
                    let recents = realm.objects(CurrentObject).filter("isFavourite == 0")
                    try! realm.write {
                        realm.delete(recents)
                        NSNotificationCenter.defaultCenter().postNotificationName(CurrentObject.Notification.Identifier.didSaveCurrentObject, object: nil)
                    }
                }
            }))
            UIApplication.delay(0.1, closure: { () -> () in
                self.presentViewController(a, animated: true, completion: nil)
            })
            
        // License
        case .License :
            presentViewController(self.getAcknowledgementsNavigationViewController(), animated: true, completion: nil)
        default :
            return
        }
    }
    
    func getAcknowledgementsNavigationViewController() -> UINavigationController {
        let plist = NSBundle.mainBundle().pathForResource("Pods-acknowledgements", ofType: "plist")
        let acks = WAAcknowledgementsViewController(acknowledgementsPlistPath: plist)
        let acksNav = UINavigationController(rootViewController: acks!)
        return acksNav
    }
    
}
