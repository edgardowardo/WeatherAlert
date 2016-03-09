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
    
    enum Items : Int {
        case Units = 0, Distance, Bin, License, Disclaimer, Donation
    }
    
    lazy var donationNavigationViewController : UINavigationController? = self.getDonationsNavigationViewController()
    var mainViewController: UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        cell.textLabel?.font = UIFont(name: "HelveticaNeue-Thin", size: 20)
        
        if let app = AppObject.sharedInstance {
            switch indexPath.row {
            case Items.Units.rawValue :
                cell.textLabel?.text = "\(app.units) and °\(app.units.temperature)"
            case Items.Distance.rawValue :
                cell.textLabel?.text = "Approximately \(app.distance * 2) \(app.units.short)"
            default :
                return cell
            }
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
            
        // Distance
        case .Distance :
            let controller = UIViewController();
            let slider = UISlider(frame: CGRectMake(10.0, 10.0, 250.0, 25.0))
            slider.minimumValue = 1
            slider.maximumValue = 20
            slider.value = Float((AppObject.sharedInstance?.distanceKm)!)
            controller.view.addSubview(slider)
            
            let alert = UIAlertController(title: " ", message: "Set approximate distance of 'nearby' city wind stations.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: { (action: UIAlertAction!) in
                if let app = AppObject.sharedInstance, realm = try? Realm() {
                    try! realm.write {
                        app.distanceKm = Double(slider.value)
                    }
                    self.tableView.reloadData()
                }
            }))
            alert.view.addSubview(controller.view)
            UIApplication.delay(0.1, closure: { () -> () in
                self.presentViewController(alert, animated: true, completion: nil)
            })
            
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
        // Diclaimer
        case .Disclaimer :
            let a = UIAlertController(title: "Disclaimer", message: "The information contained in the app is provided for general information purposes only and do not claim to be or constitute legal or other professional advice and shall not be relied upon as such. \n\nWe accept no liability or responsibility to any person or organisation as a consequence of any reliance upon the information contained in this app. \n\nInformation from city weather stations are provided by OpenWeatherMap. ", preferredStyle: UIAlertControllerStyle.Alert)
            a.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
            UIApplication.delay(0.1, closure: { () -> () in
                self.presentViewController(a, animated: true, completion: nil)
            })
        case .Donation :
            presentViewController(self.donationNavigationViewController!, animated: true, completion: nil)
        }
    }
    
    func getDonationsNavigationViewController() -> UINavigationController {
        let vc = UIStoryboard.donationViewController()!
        let nav = UINavigationController(rootViewController: vc)
        return nav
    }
    
    func getAcknowledgementsNavigationViewController() -> UINavigationController {
        let plist = NSBundle.mainBundle().pathForResource("Pods-acknowledgements", ofType: "plist")
        let acks = WAAcknowledgementsViewController(acknowledgementsPlistPath: plist)
        let acksNav = UINavigationController(rootViewController: acks!)
        return acksNav
    }
    
}
