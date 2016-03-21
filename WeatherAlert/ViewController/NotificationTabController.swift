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
        
        
    }
    
    @IBAction func close(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
