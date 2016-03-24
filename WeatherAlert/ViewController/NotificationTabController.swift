//
//  NotificationTabController.swift
//  WeatherAlert
//
//  Created by EDGARDO AGNO on 21/03/2016.
//  Copyright © 2016 EDGARDO AGNO. All rights reserved.
//

import Foundation
import UIKit


class NotificationTabController : UITabBarController {
    
    // MARK: - View lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let _ = self.presentingViewController {
            if self == (self.navigationController?.viewControllers.first!)! as UIViewController {
                self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: Selector("close:"))
            }
        }
        self.title = "Notifications"
        resetRightBarButtonItem()
    }
    
    func resetRightBarButtonItem() {
        let i : UIImage =  UIImage(named: "icon-trash-white")!
        let map = UIButton(type: .Custom)
        map.bounds = CGRectMake(0, 0, i.size.width, i.size.height)
        map.setImage(i, forState: .Normal)
        map.addTarget(self, action: Selector("clickTrash"), forControlEvents: .TouchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: map)
    }
    
    func clickTrash() {
        let a = UIAlertController(title: "Clear notifications", message: "Continue to clear all notifications? This cannot be undone.", preferredStyle: UIAlertControllerStyle.Alert)
        a.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default, handler: nil))
        a.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.Default, handler: {(alert: UIAlertAction!) in
            NotificationObject.deleteNotifications()
        }))
        self.presentViewController(a, animated: true, completion: nil)
    }
    
    
    @IBAction func close(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
